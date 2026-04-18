# ARK CRM — Assessment-Detailmaske Schema v0.3

**Stand:** 17.04.2026 (Sync-Update von v0.2)
**Status:** Sync-Patch v0.2 → v0.3 — Review ausstehend
**Quellen:** Wiki [[diagnostik-assessment]], [[offerte-diagnostik]], ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md (Konsistenz), ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3.md TEIL 8b (Flows), Entscheidungen 2026-04-13 (Credits-Modell) + 2026-04-14 (Typisierte Credits) + **2026-04-17 (Sync nach Mockup-Build: Invoiced raus + Phase-1-Typen-Kommentar)**
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md` → v0.3 (Begleit-Sync)

## Changelog v0.2 → v0.3 (17.04.2026)

| # | Änderung | Sektion | Grund |
|---|----------|---------|-------|
| 1 | **Order-Status `invoiced` entfernt** — Order-Status-Flow: Offered → Ordered → Partially Used → Fully Used → Cancelled (5 Status, kein Invoiced) | § 4.1 Titel-Zeile + § 13 Kern-Tabellen `fact_assessment_order.status` ENUM | Rechnung wird unmittelbar nach Ordered fällig (Credits-Modell). Rechnungs-Bezahl-State lebt auf `fact_assessment_billing.status` (unverändert: `pending/invoiced/paid/overdue`), nicht auf Order-Level. User-Klarstellung 2026-04-17. |
| 2 | **Phase-1-Typen-Kommentar** im § 0 Zielbild ergänzt | § 0 ZIELBILD | Mockup-Phase 1 nutzt nur MDI/Relief/ASSESS 5.0/EQ Test (SCHEELEN-Produkte). DISC/6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad bleiben im Katalog aktiv, sind aber nicht Launch-Scope. |

## Changelog v0.1 → v0.2

| # | Änderung | Sektion |
|---|----------|---------|
| 1 | **Credits-Modell-Revision: Credits sind typisiert** (MDI/Relief/ASSESS 5.0/DISC/EQ/...). Ein Paket kann gemischte Typen enthalten. | § 0, § 14 |
| 2 | Datenmodell: `fact_assessment_order.credits_total` entfernt, stattdessen Bridge `fact_assessment_order_credits(order_id, assessment_type_id, quantity, used_count)` | § 14 |
| 3 | Neue Stammdaten-Tabelle `dim_assessment_types` (MDI, Relief, ASSESS 5.0, DISC, EQ, Scheelen 6HM, Driving Forces, Human Needs/BIP, Ikigai, AI-Analyse, Teamrad-Session) | § 14 |
| 4 | Snapshot-Bar 5 → 7 Slots (inkl. Credits-Mix + Package-Name) | § 4.3 |
| 5 | Tab 1 Sektion 2 "Credits" wird Tabelle pro Typ | § 5.2 |
| 6 | Tab 2 Durchführungen: neue Spalte "Typ", Filter Multi-Select | § 6 |
| 7 | Credit-Zuweisung: Typ-Pflichtfeld; Umwidmung nur **innerhalb gleichen Typs** | § 6.5/6.6 |
| 8 | `fact_candidate_assessment_version` als zentrale Versionierungs-Tabelle (FK von Run) | § 14 |

---

## 0. ZIELBILD

Vollseite `/assessments/[id]` — Detailansicht eines Assessment-Auftrags (Diagnostik & Assessment-Dienstleistung via SCHEELEN®).

**Datenmodell-Prinzip (Credits-Modell, typisiert v0.2):**
Ein Assessment-Auftrag ist ein **gekauftes Paket mit typisierten Credits**. Jeder Credit hat einen **Assessment-Typ** (z.B. MDI, Relief, ASSESS 5.0, DISC, EQ). Ein Paket kann gemischte Typen enthalten (z.B. "1× MDI + 1× Relief + 1× ASSESS 5.0").

Jeder Credit wird einer Person zugewiesen und bei Durchführung verbraucht. Solange ein Credit noch nicht durchgeführt ist (Status ≤ `scheduled`), kann die zugewiesene Person **umgewidmet** (getauscht) werden — **nur innerhalb des gleichen Typs** (MDI-Credit kann Kandidat A → B, aber nicht Typ MDI → Relief).

**Assessment-Typen-Katalog** (`dim_assessment_types`):
MDI · Relief · ASSESS 5.0 · DISC · EQ Test · Scheelen 6HM · Driving Forces · Human Needs / BIP · Ikigai · AI-Analyse · Teamrad-Session

> **Phase-1-Scope (v0.3 Klarstellung 2026-04-17):** Mockup + Launch-Implementation nutzen nur **4 SCHEELEN-Produkte**: MDI · Relief · ASSESS 5.0 · EQ Test. Übrige 7 Typen (DISC/6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad) bleiben im Stammdaten-Katalog `is_active=true` für spätere Phasen. Mockups/Filter in `assessments.html` + `assessments-list.html` blenden Phase-1-fremde Typen aus, aber ohne Datenbank-Änderung.

**Primäre Nutzer:**
- AM (Owner): Auftragserstellung, Credit-Zuweisung, Umwidmung, Billing
- Admin: Freigabe grösserer Aufträge, Auswertungs-Gespräche
- Kandidat-Manager (CM): Lese-Zugriff auf Ergebnisse, Verknüpfung zu Platzierungs-Entscheidungen
- Backoffice: Rechnungserstellung
- Externer Partner (SCHEELEN): Kein direkter CRM-Zugriff; Ergebnisse werden von AM/Admin manuell übertragen (Phase 1), API-Integration Phase 2

**Abgrenzung zur [[kandidatenmaske-schema]]:** Die eigentlichen Test-Ergebnisse (DISC, EQ, Scheelen 6HM, ASSESS 5.0) werden im **Kandidaten-Assessment-Tab** gespeichert und versioniert — hier in der Assessment-Detailseite ist nur die **Auftrags-/Billing-/Credit-Verwaltung**.

---

## 1. DESIGNSYSTEM-REFERENZ

Erbt aus [[kandidatenmaske-schema]] § 0. Assessment-spezifische Tokens:

### Farb-Tokens

| Token | Hex | Verwendung |
|-------|-----|-----------|
| Assessment-Lila | `#a78bfa` | Primär-Akzent (analog Kandidaten-Assessment-Subtabs) |
| Credit-gold | `#dcb479` | Verfügbare Credits |
| Credit-used | `#5DCAA5` | Verbrauchte Credits |
| Credit-assigned | `#f59e0b` | Zugewiesene aber noch nicht durchgeführte Credits |
| Status Offered | grau | Entwurf |
| Status Ordered | amber | Unterschrieben, aktive Credits |
| Status Fully Used | teal | Alle Credits verbraucht |

### Mockup-Dateien (zu erstellen)

| # | Tab | Datei (geplant) |
|---|-----|-----------------|
| 1 | Übersicht | `assessment_uebersicht_v1.html` |
| 2 | Durchführungen | `assessment_durchfuehrungen_v1.html` |
| 3 | Billing | `assessment_billing_v1.html` |
| 4 | Dokumente | `assessment_dokumente_v1.html` |
| 5 | History | `assessment_history_v1.html` |

---

## 2. GESAMT-LAYOUT

```
┌──────────────────────────────────────────────────────────────────┐
│ Breadcrumb: Accounts / Volare Group / Assessments / AS-2026-042  │
├──────────────────────────────────────────────────────────────────┤
│ HEADER                                                             │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ Assessment AS-2026-042   [📦 Full Package]  [🟡 Ordered ▼]    │ │
│ │ Account-Link · Owner AM · Mandat-Link (falls vorhanden)        │ │
│ │                                                                  │ │
│ │ SNAPSHOT-BAR (sticky, 5 Slots)                                 │ │
│ │ 💰Preis  🎯Credits  ✅Verbraucht  ⏳Ausstehend  🤝Partner      │ │
│ │                                                                  │ │
│ │ [📞 Anrufen] [✉ Email] [📄 Offerte] [📤 Report übertragen]    │ │
│ └──────────────────────────────────────────────────────────────┘ │
│ TAB-BAR: Übersicht │ Durchführungen │ Billing │ Dokumente │ Hist │
│                                                                    │
│ TAB-CONTENT                                                        │
│ KEYBOARD-HINTS-BAR                                                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. BREADCRUMB-TOPBAR

```
Accounts / [Account-Name] / Assessments / [Auftrags-ID]      🔍 Ctrl+K  [Avatar]
```

- 4-stufig
- Bei mandatsbezogenem Assessment: zusätzlich anzeigen *"(aus Mandat: [Mandat-Name])"* als Sub-Text unter dem Breadcrumb

---

## 4. HEADER

### 4.1 Titel-Zeile

| Element | Inhalt | Interaktion |
|---------|--------|-------------|
| Auftrags-ID | z.B. `AS-2026-042` (auto-generiert) | Read-only |
| Package-Badge | 📦 Diagnostik / 📦 Full / 📦 Executive Summary | Read-only nach Erstellung |
| Status-Dropdown | Offered / Ordered / Partially Used / Fully Used / Cancelled (5 Status, **kein Invoiced** — siehe Changelog v0.3) | Dropdown mit Confirm |
| Credits-Pill | `✅3 / 📋5` (3 verbraucht von 5) | Read-only |

### 4.2 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Account-Link | `[Account-Name]` → `/accounts/[id]` |
| Owner AM | Initialen-Avatar + Name |
| Mandat-Link (konditional) | Nur wenn `mandate_id` gesetzt: `[Mandat-Name]` → `/mandates/[id]` + Option-IX-Badge |
| Bestell-Datum | `ordered_at` |
| Erstellt von | `created_by` (Initialen) |

### 4.3 Snapshot-Bar (sticky, 7 Slots)

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 💰 Preis | `fact_assessment_order.price_chf` (Gesamtpreis) |
| 2 | 🎯 Credits-Mix | Aus `fact_assessment_order_credits` aggregiert: z.B. "1 MDI · 1 Relief · 1 ASSESS 5.0" |
| 3 | ✅ Verbraucht | `SUM(used_count)` über alle Credits-Zeilen (pro Typ verfügbar im Detail) |
| 4 | ⏳ Ausstehend | `SUM(quantity − used_count)` |
| 5 | 📦 Package-Name | `package_name` (optional, z.B. "Führungs-Check") |
| 6 | 🤝 Partner | Aus beteiligten Typen aggregiert (z.B. "SCHEELEN + TTI") |
| 7 | 📅 Bestellt am | `ordered_at` |

**Credit-Progress-Bar** unter der Snapshot-Bar, visualisiert Verbrauch **pro Typ** (multi-stacked):
```
MDI       [██████████] 1/1 verbraucht
Relief    [░░░░░░░░░░] 0/1 (1 ausstehend: Max Muster, scheduled 20.04.)
ASSESS 5.0  [░░░░░░░░░░] 0/1 (frei)
```

### 4.4 Quick Actions

| Button | Wann sichtbar | Aktion |
|--------|--------------|--------|
| 📞 Anrufen | immer | Account-Kontakt-Popover |
| ✉ Email | immer | Email-Composer mit Assessment verknüpft |
| 📄 Offerte | Status = Offered/Ordered | PDF-Download oder -Preview der unterschriebenen Offerte |
| 📤 Report übertragen | Status = Ordered / Partially Used mit scheduled Credits | Öffnet Drawer zum Hochladen von SCHEELEN-Reports pro Run |
| ➕ Credit zuweisen | Ausstehende Credits > 0 | Drawer zur Kandidat-Zuweisung |

### 4.5 Tab-Bar

5 Tabs, horizontal. Keyboard `1`–`5`.

```
│ Übersicht │ Durchführungen │ Billing │ Dokumente │ History │
```

---

## 5. TAB 1 — ÜBERSICHT

### 5.1 Layout

2-col Grid, Sektionen collapsible (default offen).

### 5.2 Sektionen

#### Sektion 1 — Auftrag

| Feld | Typ | DB-Quelle |
|------|-----|-----------|
| Auftrags-ID | Read-only | `id` (+ formatierte Anzeige) |
| Account | Link-Chip | `account_id` |
| Mandat (konditional) | Link-Chip + "Option IX" Badge | `mandate_id` (nullable) |
| Package | Enum-Badge | `package_type` |
| Partner | Dropdown (Default: SCHEELEN) | `partner` |
| Ordered am | Date (read-only nach Unterschrift) | `ordered_at` |
| Erstellt von | Read-only | `created_by` |

#### Sektion 2 — Credits (typisiert, v0.2)

**Tabelle** aller gebuchten Assessment-Typen für diesen Auftrag:

| Typ | Gekauft | Verbraucht | Zugewiesen (scheduled) | Frei | Einzelpreis | Aktionen |
|-----|---------|-----------|------------------------|------|-------------|----------|
| MDI | 1 | 1 | 0 | 0 | CHF 2'500 | — |
| Relief | 1 | 0 | 1 | 0 | CHF 1'800 | [+ Credit zuweisen] |
| ASSESS 5.0 | 1 | 0 | 0 | 1 | CHF 3'200 | [+ Credit zuweisen] |

**Felder pro Zeile (DB-Quellen):**
- Typ — aus `dim_assessment_types.display_name`
- Gekauft — `fact_assessment_order_credits.quantity`
- Verbraucht — `fact_assessment_order_credits.used_count`
- Zugewiesen — `COUNT(fact_assessment_run WHERE type_id=X AND status IN ('assigned','scheduled','in_progress'))`
- Frei — `quantity − used_count − zugewiesen`
- Einzelpreis — `fact_assessment_order_credits.price_chf` (optional; wenn NULL, nur Gesamtpreis am Order verfügbar)

**Vor Status `Ordered`:** Inline-editierbar (Quantity, Einzelpreis pro Typ).
**Ab `Ordered`:** Read-only mit Lock-Icon 🔒. Nur Admin-/Admin-Override kann ändern (siehe Interactions).

**"+ Weiteren Typ hinzufügen"** Button unter der Tabelle (nur vor `Ordered`, oder per Admin-/Admin-Override): öffnet Drawer mit Dropdown aus allen verfügbaren Typen (`dim_assessment_types WHERE is_active=true`, abzüglich bereits in diesem Order).

**Kein Credits-Verfall** (bestätigt 2026-04-13).

#### Sektion 3 — Pauschalpreis

| Feld | Typ | DB-Quelle |
|------|-----|-----------|
| Preis (CHF, netto) | CHF (inline-edit vor `ordered`) | `price_chf` |
| MwSt | 8.1% Compute | — |
| Gesamtpreis brutto | Compute | — |
| Preis pro Credit (Info) | Compute: `price_chf / credits_total` | — |
| Spesen separat | Boolean-Hinweis "Nach Aufwand, separat berechnet" | Konstante aus Offerte |

#### Sektion 4 — Status & Abschluss

| Feld | Typ | DB |
|------|-----|-----|
| Status | Enum-Anzeige (aus Titel-Zeile) | `status` |
| Fälligkeits-Datum (Credits) | Optional | `credits_expiry_date` |
| Notizen | Textarea | `notes` |

#### Sektion 5 — Verknüpfungen

Read-only Zusammenstellung:
- **Kandidaten mit Credit:** Liste aller verknüpften Kandidaten (via `fact_assessment_run`)
- **Zugehöriges Mandat:** falls Option IX
- **History-Einträge:** Kurzübersicht letzte 5, Link zu Tab 5

---

## 6. TAB 2 — DURCHFÜHRUNGEN

Zentrale Arbeitsumgebung — Liste aller `fact_assessment_run`-Einträge dieses Auftrags.

### 6.1 Header-Controls

```
[➕ Credit zuweisen]  [Filter: Typ ▼]  [Filter: Status ▼]  [🔍 Suche]
```

"➕ Credit zuweisen" nur aktiv wenn **mindestens 1 freier Credit in mindestens 1 Typ** existiert. Button mit Badge (z.B. "2 frei" zeigt Anzahl freier Credits aggregiert).

**Filter "Typ"** — Multi-Select aus den im Order enthaltenen Typen (nur relevante Typen sichtbar).

**Filter "Status"** — Multi-Select (assigned/scheduled/in_progress/completed/cancelled_reassignable).

### 6.2 Tabelle — Spalten (v0.2 mit Typ)

| Spalte | Inhalt |
|--------|--------|
| **Typ** | Badge (MDI/Relief/ASSESS 5.0/...) aus `dim_assessment_types` |
| Kandidat | Foto + Name → Link `/candidates/[id]` |
| Status | Badge (siehe 6.3) |
| Zugewiesen am | `assigned_at` |
| Termin | `scheduled_at` (falls gesetzt) |
| Durchgeführt am | `completed_at` (falls gesetzt) |
| Durchgeführt von | `assigned_by` → SCHEELEN oder Intern |
| Report verfügbar | ✅ wenn verknüpfter Versions-Eintrag im Kandidaten-Assessment-Tab |
| Aktionen | Drawer / Kandidat ersetzen / Abbrechen |

### 6.3 Run-Status-Badges

| Status | Farbe | Bedeutung |
|--------|-------|-----------|
| assigned | amber | Credit ist Person zugewiesen, noch kein Termin |
| scheduled | blau | Termin vereinbart |
| in_progress | lila | Durchführung läuft |
| completed | green | Abgeschlossen, Report vorhanden |
| cancelled_reassignable | grau-dim | Kandidat abgesprungen / ersetzt — Credit ist wieder frei |

### 6.4 Run-Drawer (Klick auf Zeile)

**Inhalt:**
- Kandidat-Mini-Card (Foto, Name, Funktion, Link)
- Timeline: assigned → scheduled → in_progress → completed
- Felder:
  - `scheduled_at` (DateTime-Picker, editierbar bis `completed`)
  - `completed_at`
  - Notizen zur Durchführung
  - Verknüpfung zum Kandidaten-Assessment-Version (bei `completed`)
- Actions:
  - **"Kandidat ersetzen"** (nur wenn Status ≤ `scheduled`)
  - **"Termin setzen / ändern"** (Calendar-Picker)
  - **"Als durchgeführt markieren"** (öffnet Report-Upload-Flow)
  - **"Abbrechen & Credit freigeben"** (Status → `cancelled_reassignable`)

### 6.5 Credit-Zuweisungs-Drawer (v0.2 mit Typ-Pflicht)

Öffnet bei Klick "➕ Credit zuweisen" (entweder aus Header Quick-Action, aus Tab 1 Credit-Tabelle-Zeile, oder aus Tab 2):

1. **Assessment-Typ wählen (PFLICHT)** — Dropdown aus allen Typen mit `frei > 0` (oder "Alle Credits dieses Typs verbraucht" wenn keine freien).
   - Wenn aus Tab-1-Zeile geöffnet: Typ ist vorausgewählt und gelockt.
2. **Kandidat suchen** — Autocomplete über alle Kandidaten.
   - Kein Match: Hard-Stop "→ Als Kandidat anlegen" (gleiches Pattern wie Account Tab 3).
3. **Duplikat-Check:** Wenn Kandidat bereits einen aktiven Run **gleichen Typs** in diesem Auftrag hat (Status != `cancelled_reassignable`) → Warnung *"Max Muster hat bereits einen aktiven MDI-Credit in diesem Auftrag"* (nicht blockierend, Confirm-Dialog).
4. **Optional:** Termin setzen (kann später erfolgen).
5. **Bestätigen** → neuer `fact_assessment_run`-Eintrag mit `assessment_type_id` + Status `assigned`.
6. **Auto:** `fact_assessment_order_credits.used_count` wird erst bei Completion erhöht, nicht bei Zuweisung (zugewiesen ≠ verbraucht).

### 6.6 Kandidat-Ersetzen-Flow (Umwidmung, v0.2)

Nur wenn Run-Status ≤ `scheduled`.

**Wichtig (v0.2):** Umwidmung wechselt **nur den Kandidaten**, nicht den Assessment-Typ. Ein MDI-Credit bleibt ein MDI-Credit, wird nur einer anderen Person zugewiesen.

1. Confirm-Dialog: *"Person [X] durch neuen Kandidaten ersetzen? Der [Typ]-Credit bleibt erhalten."*
2. Kandidaten-Suche (wie bei Zuweisung)
3. Bestätigen → `fact_assessment_run.candidate_id` wird aktualisiert, `reassigned_at` + `reassigned_by` + `reassigned_from_candidate_id` geloggt. `assessment_type_id` bleibt unverändert.
4. History-Event `assessment_credit_reassigned` am alten und neuen Kandidaten

**Explizit NICHT möglich:** Typ-Wechsel (z.B. MDI-Credit als Relief einlösen). Wenn Kunde anderen Typ einlösen will → "Credit freigeben" + neu kaufen (oder Admin-/Admin-Override).

**Alternative Aktion:** "Credit freigeben" (Status → `cancelled_reassignable`) + neuen Run mit anderem Kandidaten anlegen. Unterschied: Beim Ersetzen bleibt die Run-ID erhalten (Audit-freundlich); beim Freigeben entsteht neuer Run.

### 6.7 Empty-State

> "Noch kein Credit zugewiesen. Dieser Auftrag hat [credits_total] verfügbare Credits. [➕ Credit zuweisen]"

---

## 7. TAB 3 — BILLING

### 7.1 Layout

Einfachere Struktur als Mandat — meist nur 1 Rechnung.

### 7.2 Zeilen-Typen

| Typ | Wann | Template |
|-----|------|----------|
| `full` | Default bei Unterschrift | `Vorlage_Rechnung_Diagnostics & Assessment.docx` |
| `expense` | Pro Beleg (Spesen) | Separate Zeile |

**Anzahlungs-Modell (`deposit` + `final`):** Phase 1.5 vorgemerkt — aktuell ist Default: Komplette Summe sofort bei Unterschrift fällig (Credits-Modell).

### 7.3 Tabelle

| # | Zahlung | Betrag | Fällig | Status | Rechnung |
|---|---------|--------|--------|--------|----------|
| 1 | Full | CHF X | bei Unterschrift | Badge | PDF |
| 2+ | Spesen (pro Beleg) | CHF X | nach Beleg-Eingang | Badge | PDF |

### 7.4 Status-Badges

- ⏳ Offen (amber)
- 📄 Rechnungsstellung (blau)
- ✅ Bezahlt (green)
- 🔴 Überfällig (rot)

### 7.5 Auto-Trigger

- Status `offered → ordered` (Upload unterschriebener Offerte) → Full-Rechnung automatisch als "fällig" erstellt

### 7.6 Empty-State

> "Noch keine Rechnungen. Die Hauptrechnung wird automatisch erstellt sobald die Offerte unterschrieben hochgeladen wird."

---

## 8. TAB 4 — DOKUMENTE

### 8.1 Kategorien (Assessment-spezifisch)

| Kategorie | Trigger |
|-----------|---------|
| Offerte | Erstellung → PDF-Generator; Upload unterschriebene Version → aktiviert Auftrag |
| Executive Summary | Upload nach Durchführung (pro Run oder gesamt) |
| Detail-Report | Upload als Anhang zum Executive Summary (~100 Seiten SCHEELEN-Output) |
| Rechnung | Auto-generiert aus Tab 3 |
| Spesenbelege | Manuell pro Spesenposten |
| Korrespondenz | Manuell |
| Sonstiges | Manuell |

### 8.2 Dokument-Card (Beispiel)

```
┌────────────────────────────────────┐
│ 📄 Executive_Summary_Max_Muster.pdf │
│ Kategorie: Executive Summary        │
│ Zugehörig zu Run: Max Muster        │
│ Upload: 05.04.2026, PW              │
│ 1.2 MB · v1                         │
│ [Preview] [Download] [⋯]            │
└────────────────────────────────────┘
```

### 8.3 Offerten-Generator

CTA-Button **"📄 Offerte generieren"** (nur wenn Status = Offered).

Output-PDF aus `Vorlage_Offerte Diagnostik & Assessment.docx`:
- Account-Daten + Ansprechpartner
- Package-Typ + Beschreibung
- Credits-Anzahl + Pauschalpreis
- Partner (SCHEELEN)
- Abweichende Bestimmungen (Abgrenzung, Haftungsausschluss, Spesenregelung)

### 8.4 Report-Upload-Flow (externe SCHEELEN-Dokumente)

Button **"📤 Report übertragen"** (Header) → Drawer:
1. Run auswählen (Dropdown aller `scheduled` / `in_progress` Runs)
2. Executive Summary PDF Upload (Pflicht)
3. Detail-Report PDF Upload (optional, SCHEELEN-Anhang)
4. Bestätigen → Auto-Aktionen:
   - Run-Status → `completed`, `completed_at = now`
   - `credits_used += 1`
   - Versions-Eintrag im Kandidaten-Assessment-Tab (siehe [[kandidat]]-Schema) verknüpft mit `assessment_order_id`
   - History-Event `assessment_run_completed` am Kandidaten + Account
   - Wenn `credits_used == credits_total`: Order-Status → `fully_used`

---

## 9. TAB 5 — HISTORY

### 9.1 Scope

Alle Events zu diesem Auftrag UND allen zugewiesenen Runs:
- Auftrag erstellt / unterschrieben / storniert
- Credit zugewiesen / ersetzt / freigegeben
- Termin vereinbart / verschoben
- Durchführung abgeschlossen
- Report hochgeladen
- Rechnung erstellt / bezahlt

### 9.2 Layout

Analog Mandat-History. Einträge chronologisch, mit Activity-Type-Icon + Kandidat (wenn relevant) + Notiz.

### 9.3 Filter

- Activity-Typ
- Kandidat (Dropdown über beteiligte Personen)
- Zeitraum

---

## 10. KEYBOARD-HINTS-BAR

**Global:** `1`–`5` Tab · `Ctrl+K` Suche · `Esc` Drawer schliessen

**Tab 1 Übersicht:** `E` Edit-Mode · `S` Save
**Tab 2 Durchführungen:** `+` Credit zuweisen · `R` Report übertragen (aktiver Run)
**Tab 3 Billing:** `R` Rechnung erstellen · `P` Als bezahlt markieren
**Tab 4 Dokumente:** `U` Upload · `G` Offerte generieren

---

## 11. RESPONSIVE-VERHALTEN

**Desktop (≥ 1280px):** 2-col Sektionen-Grid Tab 1.
**Tablet (768–1279px):** Snapshot-Bar 2-zeilig, Sektionen 1-col.
**Mobile (< 768px):** Phase 2.

---

## 12. BERECHTIGUNGEN (RBAC)

| Aktion | AM (Owner Account) | AM (andere) | Admin | CM | Backoffice |
|--------|-------------------|-------------|---------|-----|-----------|
| Lesen (alle Tabs) | ✅ | ✅ | ✅ | ✅ | Tab 3, 4 |
| Auftrag erstellen | ✅ | ❌ | ✅ | ❌ | ❌ |
| Credit zuweisen / umwidmen | ✅ | ❌ | ✅ | ❌ | ❌ |
| Termin setzen | ✅ | ❌ | ✅ | ❌ | ❌ |
| Report übertragen | ✅ | ❌ | ✅ | ❌ | ❌ |
| Rechnung erstellen | ✅ | ❌ | ✅ | ❌ | ✅ |
| Als bezahlt markieren | ⚠ | ❌ | ✅ | ❌ | ✅ |
| Auftrag stornieren | ⚠ | ❌ | ✅ | ❌ | ❌ |
| Dokument Upload | ✅ | ❌ | ✅ | ❌ | ✅ |

---

## 13. DATENBANK-REFERENZ (v0.2 typisiertes Credits-Modell)

### Neue Stammdaten-Tabelle

```sql
dim_assessment_types (NEU v0.2)
  id uuid PK,
  tenant_id FK,
  type_key VARCHAR UNIQUE,      -- 'mdi','relief','outmatch','disc','eq','scheelen_6hm',
                                -- 'driving_forces','human_needs','ikigai','ai_analyse','teamrad'
  display_name VARCHAR NOT NULL, -- Anzeigename (de/en)
  description_md TEXT,
  default_duration_minutes INT,
  partner VARCHAR,               -- 'SCHEELEN','TTI','internal'
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT
```

### Kern-Tabellen

```sql
fact_assessment_order (
  id uuid PK,
  tenant_id FK,
  account_id FK NOT NULL,
  mandate_id FK NULL,                    -- Option IX wenn gesetzt
  package_name VARCHAR NULL,             -- optionaler Paket-Name (z.B. "Führungs-Check")
  price_chf DECIMAL(10,2) NOT NULL,      -- Gesamt-Pauschale netto (kann auch aus credits-Einzelpreisen aggregiert werden)
  partner VARCHAR NULL,                  -- DEPRECATED — Partner lebt jetzt auf dim_assessment_types
                                         -- bleibt für Legacy/einfache Fälle, default NULL
  status ENUM('offered','ordered','partially_used','fully_used','cancelled'),  -- v0.3: 'invoiced' entfernt (Billing-State lebt auf fact_assessment_billing.status)
  ordered_at TIMESTAMP NULL,
  signed_document_id FK NULL,
  notes TEXT,
  created_at, updated_at,
  created_by FK, updated_by FK
)

fact_assessment_order_credits (NEU v0.2 — Bridge Order ↔ Typ)
  id uuid PK,
  tenant_id FK,
  assessment_order_id FK NOT NULL,
  assessment_type_id FK NOT NULL,        -- welcher Typ
  quantity INT NOT NULL,                 -- gekaufte Anzahl
  price_chf DECIMAL(10,2) NULL,          -- Einzelpreis je Typ (optional)
  used_count INT NOT NULL DEFAULT 0,     -- Live-Zähler (wird bei Completion erhöht)
  created_at, updated_at,
  UNIQUE(assessment_order_id, assessment_type_id)
  -- CHECK: used_count <= quantity
  -- CHECK: quantity > 0

fact_assessment_run (REVIDIERT v0.2)
  id uuid PK,
  assessment_order_id FK NOT NULL,
  assessment_type_id FK NOT NULL,        -- NEU: welcher Typ wird durchgeführt
  candidate_id FK NOT NULL,
  status ENUM('assigned','scheduled','in_progress','completed','cancelled_reassignable'),
  assigned_at TIMESTAMP NOT NULL,
  assigned_by FK NOT NULL,
  scheduled_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  reassigned_at TIMESTAMP NULL,          -- bei Umwidmung
  reassigned_by FK NULL,
  reassigned_from_candidate_id FK NULL,   -- Audit-Trail beim Tausch
  result_version_id FK NULL,             -- FK zu fact_candidate_assessment_version
  notes TEXT,
  created_at, updated_at

fact_assessment_billing (UNVERÄNDERT)
  id uuid PK,
  assessment_order_id FK NOT NULL,
  billing_type ENUM('full','deposit','final','expense'),
  amount_chf DECIMAL(10,2),
  due_date DATE,
  invoice_number VARCHAR(50),
  invoice_date DATE,
  paid_at TIMESTAMP NULL,
  status ENUM('pending','invoiced','paid','overdue'),
  pdf_document_id FK NULL,
  created_at, updated_at
```

### Kandidaten-Seite: Neue zentrale Versionierungs-Tabelle

```sql
fact_candidate_assessment_version (NEU v0.2 — Entscheidung #11)
  id uuid PK,
  tenant_id FK,
  candidate_id FK NOT NULL,
  assessment_order_id FK NULL,           -- NULL bei Legacy/Manual-Eingabe
  assessment_type_id FK NOT NULL,        -- welcher Test-Typ
  version_number INT NOT NULL,           -- aufsteigend pro (candidate_id, type_id)
  version_date TIMESTAMP NOT NULL,
  executive_summary_doc_id FK NULL,
  detail_report_doc_id FK NULL,
  result_data JSONB,                     -- Test-spezifische Rohdaten (JSON-Schema je Typ)
  created_at, created_by
```

Existierende Detail-Tabellen (DISC, EQ, Scheelen 6HM Details etc.) bekommen `version_id FK` → `fact_candidate_assessment_version.id`.

### Invariants / Constraints

- `fact_assessment_run.assessment_type_id` muss in `fact_assessment_order_credits` dieses Orders existieren (sonst Run auf einen Typ den der Kunde nicht gekauft hat)
- Umwidmungs-Constraint: bei UPDATE `candidate_id` darf `assessment_type_id` nicht ändern (Trigger-validiert)
- `used_count`-Increment nur bei Run-Completion (atomar in Transaktion, nicht bei Zuweisung)

---

## 14. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions v0.2 mit Typisierten Credits (direkt folgend) | P0 |
| 2 | Mockup-HTMLs für 5 Tabs (mit neuem Credits-Tabellen-Layout) | P1 |
| 3 | ~~Credits-Verfall~~ | Geklärt 2026-04-13: **Kein Verfall** |
| 4 | Anzahlungs-Modell (`deposit` + `final`) für grössere Aufträge | Phase 1.5 |
| 5 | SCHEELEN-API-Integration (Auto-Report-Import) | Phase 2 |
| 6 | Terminkalender-Sync (Outlook/Google) für `scheduled_at` | Phase 2 |
| 7 | ~~Multi-Mandat-Zuordnung~~ | Geklärt 2026-04-14: **1:1 beibehalten** |
| 8 | ~~Multi-Kandidaten-Credits~~ | Geklärt 2026-04-14: **Typisierte Credits-Bridge** |
| 9 | Scheelen-CSV-Import (separater Workflow, Phase 1.5) vs. PDF-Report-Upload — Abgrenzung | Phase 1.5 |
| 10 | Admin-/Admin-Override-UI für Credit-Quantity-Änderung nach `Ordered` | P1 |

---

## 15. RELATED SPECS / WIKI

- `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_2.md`
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2.md` — Konsistenz-Referenz (Option IX Verknüpfung)
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_2.md` + `INTERACTIONS_v0_3.md` TEIL 8b — Assessment-Beauftragungs-Flow am Account
- `ARK_KANDIDATENMASKE_SCHEMA_v1_3.md` — Assessment-Tab im Kandidaten (DISC, EQ, Scheelen 6HM, ASSESS 5.0)
- `ARK_STAMMDATEN_EXPORT_v1_3.md` (ausstehend) — `dim_assessment_types` Katalog
- [[audit-entscheidungen-2026-04-14]] — Credits-Typen-Entscheidung
- [[diagnostik-assessment]], [[offerte-diagnostik]]
- [[assessment]] (Konzept für Test-Ergebnisse im Kandidaten)
- [[honorar-berechnung]] § 5
- [[detailseiten-guideline]]
