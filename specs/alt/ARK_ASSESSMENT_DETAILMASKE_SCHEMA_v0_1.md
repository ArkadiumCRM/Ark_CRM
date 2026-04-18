# ARK CRM — Assessment-Detailmaske Schema v0.1

**Stand:** 13.04.2026
**Status:** Erstentwurf — Review ausstehend
**Quellen:** Wiki [[diagnostik-assessment]], [[offerte-diagnostik]], ARK_MANDAT_DETAILMASKE_SCHEMA_v0_1.md (Konsistenz), ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_2.md TEIL 8b (Flows), Entscheidungen 2026-04-13 (Credits-Modell)
**Vorrang:** Stammdaten > dieses Schema > Frontend Freeze > Mockups
**Begleitdokument:** `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md` (Verhalten, Flows, Events)

---

## 0. ZIELBILD

Vollseite `/assessments/[id]` — Detailansicht eines Assessment-Auftrags (Diagnostik & Assessment-Dienstleistung via SCHEELEN®).

**Datenmodell-Prinzip (Credits-Modell):**
Ein Assessment-Auftrag ist ein **gekauftes Paket mit N Credits**. Jeder Credit wird einer Person zugewiesen und bei Durchführung verbraucht. Solange ein Credit noch nicht durchgeführt ist (Status ≤ `scheduled`), kann die zugewiesene Person **umgewidmet** (getauscht) werden — der Kunde hat quasi "Guthaben" für Assessments.

**Primäre Nutzer:**
- AM (Owner): Auftragserstellung, Credit-Zuweisung, Umwidmung, Billing
- Admin: Freigabe grösserer Aufträge, Auswertungs-Gespräche
- Kandidat-Manager (CM): Lese-Zugriff auf Ergebnisse, Verknüpfung zu Platzierungs-Entscheidungen
- Backoffice: Rechnungserstellung
- Externer Partner (SCHEELEN): Kein direkter CRM-Zugriff; Ergebnisse werden von AM/Admin manuell übertragen (Phase 1), API-Integration Phase 2

**Abgrenzung zur [[kandidatenmaske-schema]]:** Die eigentlichen Test-Ergebnisse (DISC, EQ, Scheelen 6HM, Outmatch) werden im **Kandidaten-Assessment-Tab** gespeichert und versioniert — hier in der Assessment-Detailseite ist nur die **Auftrags-/Billing-/Credit-Verwaltung**.

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
| Status-Dropdown | Offered / Ordered / Partially Used / Fully Used / Invoiced / Cancelled | Dropdown mit Confirm |
| Credits-Pill | `✅3 / 📋5` (3 verbraucht von 5) | Read-only |

### 4.2 Meta-Zeile

| Element | Inhalt |
|---------|--------|
| Account-Link | `[Account-Name]` → `/accounts/[id]` |
| Owner AM | Initialen-Avatar + Name |
| Mandat-Link (konditional) | Nur wenn `mandate_id` gesetzt: `[Mandat-Name]` → `/mandates/[id]` + Option-IX-Badge |
| Bestell-Datum | `ordered_at` |
| Erstellt von | `created_by` (Initialen) |

### 4.3 Snapshot-Bar (sticky, 5 Slots)

| Slot | Inhalt | Source |
|------|--------|--------|
| 1 | 💰 Preis | `fact_assessment_order.price_chf` |
| 2 | 🎯 Credits total | `credits_total` |
| 3 | ✅ Verbraucht | `credits_used` (Runs mit Status `completed`) |
| 4 | ⏳ Ausstehend | `credits_total − credits_used − credits_cancelled` |
| 5 | 🤝 Partner | `partner` (Default: SCHEELEN) |

**Credit-Progress-Bar** unter der Snapshot-Bar, visualisiert Verbrauch:
```
[██████░░░░] 3/5 Credits verbraucht · 1 zugewiesen, noch nicht durchgeführt · 1 frei
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

#### Sektion 2 — Credits

| Feld | Typ | DB-Quelle |
|------|-----|-----------|
| Credits gesamt | Int (inline-edit vor `ordered`, read-only danach) | `credits_total` |
| Credits verbraucht | Read-only, Compute | `COUNT(fact_assessment_run WHERE status='completed')` |
| Credits zugewiesen | Read-only, Compute | `COUNT(fact_assessment_run WHERE status IN ('assigned','scheduled','in_progress'))` |
| Credits frei | Read-only, Compute | `credits_total − zugewiesen − verbraucht − cancelled` |
| ~~Ablauf Credits~~ | — | **Entfernt (kein Verfall, Entscheidung 2026-04-13)** |

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
[➕ Credit zuweisen]  [Filter ▼]  [🔍 Suche]
```

"➕ Credit zuweisen" nur aktiv wenn `credits_frei > 0`.

### 6.2 Tabelle — Spalten

| Spalte | Inhalt |
|--------|--------|
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

### 6.5 Credit-Zuweisungs-Drawer

Öffnet bei Klick "➕ Credit zuweisen":

1. **Kandidat suchen** — Autocomplete über alle Kandidaten
   - Kein Match: Hard-Stop "→ Als Kandidat anlegen" (gleiches Pattern wie Account Tab 3)
2. **Duplikat-Check:** Wenn Kandidat bereits einen aktiven Run in diesem Auftrag hat (Status != `cancelled_reassignable`) → Warnung *"Diese Person hat bereits einen Credit in diesem Auftrag zugewiesen"* (nicht blockierend, Confirm-Dialog)
3. **Optional:** Termin setzen (kann später erfolgen)
4. **Bestätigen** → neuer `fact_assessment_run`-Eintrag mit Status `assigned`

### 6.6 Kandidat-Ersetzen-Flow (Umwidmung)

Nur wenn Run-Status ≤ `scheduled`.

1. Confirm-Dialog: *"Person [X] durch neuen Kandidaten ersetzen? Der Credit bleibt erhalten."*
2. Kandidaten-Suche (wie bei Zuweisung)
3. Bestätigen → `fact_assessment_run.kandidat_id` wird aktualisiert, `reassigned_at` + `reassigned_by` geloggt
4. History-Event `assessment_credit_reassigned` am alten und neuen Kandidaten

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

## 13. DATENBANK-REFERENZ

```sql
fact_assessment_order (
  id uuid PK,
  tenant_id FK,
  account_id FK NOT NULL,
  mandate_id FK NULL,                    -- Option IX wenn gesetzt
  package_type ENUM('diagnostik_only','full_package','executive_summary_only'),
  credits_total INT NOT NULL,            -- typischerweise 1–10
  price_chf DECIMAL(10,2) NOT NULL,      -- Pauschale netto
  partner VARCHAR(100) DEFAULT 'SCHEELEN',
  status ENUM('offered','ordered','partially_used','fully_used','invoiced','cancelled'),
  ordered_at TIMESTAMP NULL,
  signed_document_id FK NULL,
  -- credits_expiry_date entfernt: kein Verfall (Entscheidung 2026-04-13)
  notes TEXT,
  created_at, updated_at,
  created_by FK, updated_by FK
)

fact_assessment_run (
  id uuid PK,
  assessment_order_id FK NOT NULL,
  kandidat_id FK NOT NULL,
  status ENUM('assigned','scheduled','in_progress','completed','cancelled_reassignable'),
  assigned_at TIMESTAMP NOT NULL,
  assigned_by FK NOT NULL,
  scheduled_at TIMESTAMP NULL,
  completed_at TIMESTAMP NULL,
  reassigned_at TIMESTAMP NULL,          -- bei Umwidmung
  reassigned_by FK NULL,
  reassigned_from_kandidat_id FK NULL,   -- Audit-Trail beim Tausch
  result_version_id FK NULL,             -- FK zu Kandidaten-Assessment-Version
  notes TEXT,
  created_at, updated_at
)

fact_assessment_billing (
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
)
```

**Kandidaten-Seite:** In `fact_candidate_assessments` (bestehend) wird ein neues Feld `assessment_order_id FK NULL` ergänzt — verknüpft die Versions-Einträge (DISC, EQ, Scheelen 6HM, Outmatch) mit dem auslösenden Auftrag. Versionierung-Logik bleibt wie bisher.

---

## 14. OFFENE SPEC-PUNKTE

| # | Punkt | Priorität |
|---|-------|-----------|
| 1 | Interactions-Spec `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md` | P0 (direkt nächster Schritt) |
| 2 | Mockup-HTMLs für 5 Tabs | P1 |
| 3 | ~~Credits-Verfall~~ | Geklärt 2026-04-13: **Kein Verfall** (weder Phase 1 noch 2) |
| 4 | Anzahlungs-Modell (`deposit` + `final`) für grössere Aufträge | Phase 1.5 |
| 5 | SCHEELEN-API-Integration (Auto-Report-Import) | Phase 2 |
| 6 | Terminkalender-Sync (Outlook/Google) für `scheduled_at` | Phase 2 |
| 7 | Multi-Mandat-Zuordnung? (Ein Auftrag für mehrere Mandate?) | Klärung |

---

## 15. RELATED SPECS / WIKI

- `ARK_ASSESSMENT_DETAILMASKE_INTERACTIONS_v0_1.md` (ausstehend)
- `ARK_MANDAT_DETAILMASKE_SCHEMA_v0_1.md` — Konsistenz-Referenz (Option IX Verknüpfung)
- `ARK_ACCOUNT_DETAILMASKE_SCHEMA_v0_1.md` + `INTERACTIONS_v0_2.md` TEIL 8b — Assessment-Beauftragungs-Flow am Account
- `ARK_KANDIDATENMASKE_SCHEMA_v1_2.md` — Assessment-Tab im Kandidaten (SCHEELEN, DISC, EQ, Outmatch)
- [[diagnostik-assessment]], [[offerte-diagnostik]]
- [[assessment]] (Konzept für Test-Ergebnisse im Kandidaten)
- [[honorar-berechnung]] § 5
- [[detailseiten-guideline]]
