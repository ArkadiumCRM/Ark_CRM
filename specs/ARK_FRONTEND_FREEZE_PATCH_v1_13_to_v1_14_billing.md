---
title: "ARK Frontend-Freeze · Patch v1.13 → v1.14 · Billing-Modul"
type: patch
phase: 3
created: 2026-04-30
updated: 2026-04-30
status: draft
depends_on: [
  "specs/ARK_BILLING_INTERACTIONS_v0_1.md (authoritative Routes/Sidebar/UI-source)",
  "specs/ARK_BILLING_SCHEMA_v0_1.md (Schema-Refs)",
  "specs/ARK_BILLING_PLAN_v0_1.md (Phase-Plan + Rollen-Matrix)",
  "specs/ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md (UI-Label-Vocabulary)",
  "specs/ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md (Tabellen-Referenz)",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md (Endpoints)"
]
target: "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md → v1.14 (neuer Abschnitt §4i Operations · Billing)"
tags: [frontend, patch, billing, phase-3, routing, sidebar, drawer, rbac, qr-bill]
---

# ARK Frontend-Freeze · Patch v1.13 → v1.14 · Billing-Modul

**Stand:** 2026-04-30
**Status:** Draft · ergänzend zu Phase-1-A-Sync-Patch (`ARK_FRONTEND_FREEZE_PATCH_v1_13_to_v1_14_phase1a.md`)
**Quellen:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` (Vorgänger · §6 Sidebar-Gruppierung · §7 Routenmodell · §4 Operations)
- `specs/ARK_BILLING_INTERACTIONS_v0_1.md` §1.1 (Routen) · §1.2 (Sidebar) · §2 (Screens) · §3 (Drawer-Specs) · §10 (UI-Patterns) · §11 (UI-Label-Vocabulary)
- `specs/ARK_BILLING_SCHEMA_v0_1.md` §1 (Scope · Tabellen) · §13 (Sync-Checkliste)
- `specs/ARK_BILLING_PLAN_v0_1.md` §7 (Rollen-Matrix) · §9 (Phasen-Plan)
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md` §M.4 (REST-Endpoints)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.4 → v1.5 (Billing-Tabellen + Adress-Erweiterung) deployed
- Backend-Patch v2.6 → v2.7 (Billing-Events · Worker · Sagas · Endpoints) deployed
- Stammdaten-Patch v1.4 → v1.5 (§91 Billing-Stammdaten) deployed

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch ergänzt Frontend-Freeze v1.13 um einen vollständigen neuen Operations-Bereich im Schema „Billing" (User-facing Sidebar-Label „**Finanzen**"). Drei Bausteine:

1. **§4i Operations · Billing** — neuer Top-Level-Abschnitt analog §4f Email & Kalender + §4h Performance-Modul: 11 Top-Level-Routen + 9-Eintrag-Sidebar-Tree + 7 UI-Patterns (KPI-Bar, Filter, Mahnstufen-Pipeline, Aging, Treuhand-Mode, RLS, Cockpit) + Drawer-Inventar.
2. **Drawer-Inventar (10 Drawer + 1 Modal)** — vollständige Liste der 540px-Slide-In-Drawer (Drawer-Default-Regel) und einer 420px-Confirm-Modale.
3. **Permission-Matrix (4 Rollen · 11 Routen)** — Backoffice / GF / AM (RLS) / Treuhand (Read-Only) je Route + spezifische Aktionen.

---

## 1. Routenmodell-Ergänzung (§4i Operations · Billing)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_13.md` §7 Routenmodell. Alle 11 Top-Level-Routen aus `ARK_BILLING_INTERACTIONS_v0_1.md` §1.1 übernommen.

### 1.1 Top-Level-Routen (11)

| Route | Screen | Default-Tab | Zielgruppe | RLS-Hinweis |
|-------|--------|-------------|-----------|-------------|
| `/billing` | Billing-Dashboard | KPIs + Aging | Backoffice · GF | — (BO/GF sehen alles) |
| `/billing/rechnungen` | Rechnungs-Liste | alle aktiv | Backoffice · GF · AM | AM filtert auto auf eigene Mandate (`fact_invoice.mandate_id ∈ AM-Owner-Set`) |
| `/billing/rechnungen/:invoice_id` | Rechnung-Detail (Drawer-Flow) | Positionen | Backoffice · GF | Tab-State per URL |
| `/billing/mahnwesen` | Mahnwesen-Cockpit | pending Stufen | Backoffice · GF | — |
| `/billing/debitoren` | Debitoren-Liste | offene Salden | Backoffice · GF · AM | AM-RLS filtert auf eigene Kunden (`dim_accounts.owner_am_id`) |
| `/billing/debitoren/:customer_id` | Debitor-Konto | Ledger | Backoffice · GF · AM | AM nur eigene |
| `/billing/zahlungen` | Zahlungseingang | Unmatched | Backoffice · GF | — |
| `/billing/refunds` | Refund-Cockpit | offene Garantie-Fälle | Backoffice · GF | GF-Approval-Pflicht für Issue |
| `/billing/mwst` | MwSt-Abrechnung | aktuelles Quartal | Backoffice · GF · Treuhand (RO) | Read-Only-Modus für Treuhand |
| `/billing/inkasso` | Inkasso-Liste | aktive Verfahren | Backoffice · GF | GF-Pflicht für Übergabe |
| `/billing/export/treuhand` | Treuhand-Export | monatliche Batches | Backoffice · Treuhand (RO) | Read-Only-Modus für Treuhand |

### 1.2 URL-State-Sync (Filter / Tabs)

```text
?status=draft|approved|issued|partial|paid|overdue|dunning_1|dunning_2|dunning_3|disputed|gestundet|cancelled|refunded|written_off
?type=erfolg|akonto|zwischen|schluss|mandat_time_monthly|kuendigung|optionale_stage|assessment|bonus_schutzfrist|refund|gutschrift|storno
?customer_id=<uuid>                  → Autocomplete-Filter (Multi)
?sparte=ARC|GT|ING|PUR|REM           → Sparten-Filter (Multi)
?date_from=YYYY-MM-DD&date_to=…      → Datum-Range (Issue-Datum oder Fälligkeit)
?amount_min=…&amount_max=…           → Betrags-Range
?agb_version=<code>                  → AGB-Version (z.B. agb-feb-2023)
?tone=sie|du                         → Anrede-Filter
?export_status=open|exported         → Treuhand-Exportstatus
?responsible_user_id=<uuid>          → Verantwortlicher (AM/CM)
?period=7d|30d|quarter|ytd|custom    → Dashboard-/Zahlungen-Zeitraum
?confidence=high|mid|low             → Zahlungen-Match-Confidence
?cadence=key_account|standard        → Mahnwesen Kadenz-Profil
?drawer-tab=positionen|zahlungen|mahnungen|audit|pdf-preview  → Rechnungs-Detail-Drawer-Tab
?guarantee=open|exit_risk|triggered|closed   → Refund-Cockpit-Filter
```

**Browser-Back** funktioniert für alle Filter-Kombinationen (URL-State = Single-Source-of-Truth). Tab-Wechsel im Drawer schreibt `?drawer-tab=…`.

### 1.3 Komponenten-Struktur (Next.js App Router)

```text
app/
  billing/
    layout.tsx                      → Billing-Header + Tabbar (Routen 1.1) + KPI-Bar
    page.tsx                        → Dashboard
    rechnungen/
      page.tsx                      → Rechnungs-Liste
      [invoice_id]/
        page.tsx                    → Rechnung-Detail-Drawer-Flow
    mahnwesen/page.tsx
    debitoren/
      page.tsx
      [customer_id]/page.tsx
    zahlungen/page.tsx
    refunds/page.tsx
    mwst/page.tsx
    inkasso/page.tsx
    export/
      treuhand/page.tsx
```

**Mockup-Mapping (alle Phase-1-Mockups existieren):**

```text
mockups/ERP Tools/billing/
  billing.html                       ← Hub (Snapshot-Bar, Sidebar-Tree)
  billing-dashboard.html             ← /billing
  billing-rechnungen.html            ← /billing/rechnungen + :invoice_id Drawer
  billing-mahnwesen.html             ← /billing/mahnwesen
  billing-debitoren.html             ← /billing/debitoren + :customer_id
  billing-zahlungen.html             ← /billing/zahlungen
  billing-refunds.html               ← /billing/refunds
  billing-mwst.html                  ← /billing/mwst
  billing-inkasso.html               ← /billing/inkasso
```

**Treuhand-Export** (Route `/billing/export/treuhand`) wird in Phase 2 als eigenes Mockup ergänzt. Aktuell als Sub-Tab in `billing-rechnungen.html` prototypisch verfügbar.

---

## 2. Sidebar-Tree „Finanzen"

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_13.md` §6 Sidebar-Gruppierung.

### 2.1 Sidebar-Eintrag (Top-Level)

```text
-- Bestehend (v1.13):
GRUPPE 4 – Operations:
  Email & Kalender │ Performance │ HR │ Zeit │ E-Learning

-- NEU (v1.14):
GRUPPE 4 – Operations:
  Email & Kalender │ Performance │ HR │ Zeit │ E-Learning │ Finanzen
```

### 2.2 Sub-Tree „Finanzen" (Slide-Out-Sub-Menü, 9 Einträge)

UI-Label "**Finanzen**" statt "Billing" (per `ARK_BILLING_INTERACTIONS_v0_1.md` §1.2 Research-Empfehlung · User-facing Deutsch · Memory `feedback_peter_explanations_not_renames.md`).

```text
Finanzen
├── Dashboard           → /billing
├── Rechnungen          → /billing/rechnungen
├── Mahnwesen           → /billing/mahnwesen
├── Debitoren           → /billing/debitoren
├── Zahlungen           → /billing/zahlungen
├── Refunds             → /billing/refunds
├── MwSt                → /billing/mwst
├── Inkasso             → /billing/inkasso
└── Treuhand-Export     → /billing/export/treuhand
```

### 2.3 Sidebar-Item-Konfiguration

```typescript
{
  label: 'Finanzen',
  href: '/billing',
  icon: 'Receipt',          // Lucide-Icon
  group: 4,                  // Operations
  permission: ['backoffice', 'gf', 'am', 'treuhand'],
  activePattern: /^\/billing/,
  badge: {
    source: 'GET /api/v1/billing/dashboard/badge-counts',
    fields: ['overdue', 'dunning_pending', 'refund_at_risk'],
    color: 'amber',
    polling_seconds: 60,
  },
  children: [/* 9 Sub-Items siehe §2.2 */]
}
```

**Permission-Verhalten:**
- **AM** sieht „Finanzen" mit gefilterten Counts (eigene Mandate). Subroutes Mahnwesen/Inkasso/MwSt/Refunds/Zahlungen/Treuhand-Export sind ausgegraut bzw. ausgeblendet.
- **Treuhand-Login** (Read-Only-Rolle) sieht nur `Dashboard (RO)` + `MwSt (RO)` + `Treuhand-Export (RO)`. Übrige Subroutes ausgeblendet.

---

## 3. UI-Patterns (7)

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_13.md` §4 Operations-UI-Patterns.

### 3.1 4-Spalten-KPI-Bar (Dashboard)

Pattern siehe `ARK_BILLING_INTERACTIONS_v0_1.md` §2.1.

```text
┌──────────────────────────────────────────────────────────────────────┐
│  Offen gesamt    Überfällig      Eingänge 30d    MwSt-Quartal offen  │
│  CHF 387'420     CHF 124'800     CHF 562'100     CHF 31'800          │
│  → Liste         → Liste         → Zahlungen     → MwSt              │
└──────────────────────────────────────────────────────────────────────┘
```

- **Live-Refresh:** WebSocket-Channel `billing:dashboard` ODER Polling 60s (Fallback).
- **Deep-Link:** Click auf KPI öffnet vorgefilterte Liste (Query-Params aus §1.2).
- **Format:** CHF-Beträge mit Thousands-Separator (`'`), 2 Dezimalstellen.
- **Color-Coding:** Überfällig = Amber (`var(--color-warning)`), MwSt-deadline ≤ 14d = Rot.

### 3.2 Filter-Bar horizontal-scrollable (Listen)

Pattern aus `ARK_BILLING_INTERACTIONS_v0_1.md` §2.2.

- Multi-Select Chips (Status / Typ / Sparte / AGB / Tone) — re-render bei Auswahl
- Autocomplete-Felder (Kunde, Verantwortlicher) gegen `dim_accounts` / `dim_users`
- Datum-Range mit Kalender-Picker UND manueller Tastatur-Eingabe (CLAUDE.md Datum-Eingabe-Regel · native `<input type="date">`)
- Betrags-Range (Slider + manuelle CHF-Eingabe)
- Mobile: horizontale Scroll-Bar (touch + Trackpad)

### 3.3 Mahnstufen-Pipeline-Visualisierung (Column-Chart)

Pattern aus `ARK_BILLING_INTERACTIONS_v0_1.md` §2.1 Widget 1.

```text
       ┌──┐
       │  │ 8
       │  │
  ┌──┐ │  │ ┌──┐
  │  │ │  │ │  │
4 │  │ │  │ │  │ 3
──┴──┴─┴──┴─┴──┴───
 Mahn1 Mahn2 Mahn3
 pending pending pending
```

- **X-Achse:** 3 Mahnstufen (1 / 2 / 3) + 1 Inkasso-Eskalation
- **Y-Achse:** Anzahl Rechnungen mit `next_dunning_level_due ≤ today`
- **Click:** Filter `/billing/mahnwesen?level=1` öffnet Cockpit vorgefiltert

### 3.4 Aging-Buckets

Pattern auf Debitor-Konto + Listen.

| Bucket | Tage | Color |
|--------|------|-------|
| Aktuell | 0–30 | Grün |
| Leicht überfällig | 31–60 | Gelb |
| Stark überfällig | 61–90 | Orange |
| Kritisch | > 90 | Rot |

- **Rendering:** stacked horizontal bar pro Kunde (ähnlich Stage-Pill in CRM)
- **Spalte „Days overdue"** in Rechnungs-Liste mit Bucket-Farbe (Pill-Badge)
- **Debitor-Header** zeigt Aging-Verteilung als Mini-Stacked-Bar

### 3.5 Treuhand-Export-Modus (Read-Only-Filter)

Pattern für externe Treuhand-Login (`role = 'treuhand'`).

```typescript
// Layout-Wrapper
if (user.role === 'treuhand') {
  return (
    <ReadOnlyBanner>
      Treuhand-Read-Only-Modus · Editieren deaktiviert · Export aktiv
    </ReadOnlyBanner>
    {children}
  );
}
```

- **Banner** sticky oben (Treuhand-Yellow-Tinted): „Treuhand-Read-Only-Modus · Editieren deaktiviert · Export aktiv"
- **Alle Action-Buttons disabled** außer „CSV-Export" / „PDF-Download" / „MwSt-Quartal anzeigen"
- **Kein Compose-Drawer** (Mahnung / Rechnung erstellen ausgeblendet)
- **Audit-Log lesbar** (Read-Only)

### 3.6 RLS-aware Listen (AM-Filter)

Pattern für Account-Manager-Zugriff.

- **Server-side RLS** (PostgreSQL Row-Level-Security) filtert `fact_invoice` auf eigene Mandate (`fact_invoice.mandate_id IN (SELECT mandate_id FROM fact_mandate WHERE owner_am_id = current_user)` · ARK CRM 1.0).
- **Frontend-Hinweis:** Filter-Chip „Eigene Mandate (RLS aktiv)" in Header der Liste, nicht entfernbar.
- **Tooltip:** „Du siehst Rechnungen zu Mandaten, bei denen du als AM eingetragen bist. Andere Rechnungen siehst du nicht."

### 3.7 Mahnwesen-Cockpit-Pattern (4-Stufen-Spalten)

Pattern für `/billing/mahnwesen`.

```text
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ Erinnerung  │ Mahnung 1   │ Mahnung 2   │ Inkasso-Esk │
│ T+5 (soft)  │ T+15/30     │ T+30/45     │ T+50/65     │
│             │             │             │             │
│ ┌─────────┐ │ ┌─────────┐ │ ┌─────────┐ │ ┌─────────┐ │
│ │ Inv 123 │ │ │ Inv 456 │ │ │ Inv 789 │ │ │ Inv 012 │ │
│ │ Std-Kd  │ │ │ KA-Kd   │ │ │ Std-Kd  │ │ │ Std-Kd  │ │
│ └─────────┘ │ └─────────┘ │ └─────────┘ │ └─────────┘ │
│  N=4         │  N=8         │  N=3         │  N=1       │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

- **Sammelaktion oben:** „Alle Stufe X vorbereiten" → öffnet Bulk-Modal mit Preview (siehe §4.3)
- **Bei dispute_active**: gelber Pause-Icon-Overlay auf Card; Auto-Aktion blockiert
- **Bei `cadence_profile = key_account`**: blauer KA-Badge auf Card

---

## 4. Drawer-Inventar (10 Drawer + 1 Modal)

Per CLAUDE.md Drawer-Default-Regel — alle CRUD und Mehrschritt-Eingaben als 540px-Slide-In. Mahnungs-Versand als 420px-Modal (Confirm-Pattern).

### 4.1 Drawer (10)

| Drawer-Slug | Titel | Trigger | Layout | Tabs | Quelle |
|-------------|-------|---------|--------|------|--------|
| `drawer-invoice-detail` | Rechnung Detail | Row-Click `/billing/rechnungen` ODER Deep-Link `:invoice_id` | 540px Read+Action | 5 (Positionen / Zahlungen / Mahnungen / Audit / PDF-Preview) | §3.1 |
| `drawer-invoice-create` | Neue Rechnung | Button "Neue Rechnung" ODER Auto bei `invoice_triggered`-Event | 540px Multi-Step Wizard | 7 Steps (Kunde / Quelle+Typ / Positionen / MwSt+Rabatt / Anschreiben / QR-Preview / Freigabe) | §3.2 |
| `drawer-credit-note` | Gutschrift erstellen | Action „Gutschrift" aus Rechnungs-Detail | 540px Multi-Step | 6 Steps (Rechnung / Grund / Betrag / Verlinkung / GF-Approval / PDF-Preview) | §3.4 |
| `drawer-payment-match` | Zahlung erfassen | „Zahlung manuell erfassen" / Unmatched-Bookings | 540px CRUD | Single (Match-Form + Confidence) | §3.5 |
| `drawer-refund-decision` | Refund-Berechnung | Row-Click Refund-Cockpit ODER `refund_eligibility_check` | 540px Multi-Section | 8 Sections (Placement / Exit / 3-Tage-Pflicht / Ausschluss / Staffel / Clawback / GF / Auszahlung) | §3.6 |
| `drawer-inkasso-handover` | Inkasso-Übergabe | Action „Inkasso-Übergabe" GF | 540px Multi-Section | 5 Sections (Kontext / Dossier-Checklist / Partner / GF-Warning / Export) | §3.7 |
| `drawer-mandat-stage-trigger` | Mandat-Stage auslösen | Auto bei `shortlist_reached` ODER manuell aus Mandat-Detail | 540px Read+Approve | Single (Stage-Übersicht + Approve+Issue) | §3.8 |
| `drawer-bank-import` | CAMT.054-Import | Upload-Dropzone in Zahlungseingang | 540px Multi-Step | 3 Phasen (Upload / Parser-Result / Commit) | §3.9 |
| `drawer-dispute-handle` | Honorarstreit verwalten | Action „Als Honorarstreit markieren" | 540px Multi-Section | 5 Sections (Grund / Status / Dokumente / GF-Eskalation / Resolution) | §3.10 |
| `drawer-mwst-quarter-close` | MwSt-Quartal abschliessen | Button auf MwSt-Screen aktuelles Quartal | 540px Read+Approve | 3 Steps (Aggregat-Preview / ESTV-Mapping / Lock+Submit) | §2.8 |

### 4.2 Drawer-Standard-Properties

```typescript
interface BillingDrawerProps {
  width: 540;                                       // px (CLAUDE.md Drawer-Default)
  origin: 'right';                                  // Slide-in von rechts
  backdrop: 'opaque-30';                            // 30% Schwarz-Overlay
  closeBehavior: 'esc' | 'backdrop-click' | 'x';
  stickyHeader: true;                               // Title + Status-Badge
  stickyFooter: true;                               // Aktions-Buttons + Sticky-Sum (bei Editor)
  urlSync: '?drawer=…&drawer-tab=…';                // Browser-Back-fähig
  unsavedChangesGuard: true;                        // Confirm bei Close mit Dirty-State
}
```

### 4.3 Modal (1) — Mahnung-Senden-Bulk

Bewusste Ausnahme zur Drawer-Default-Regel: kurzer Confirm-Schritt vor irreversiblem Mass-Versand → 420px-Modal (CLAUDE.md erlaubt Modal für Confirms / Blocker).

| Modal-Slug | Titel | Trigger | Größe | Inhalt | Quelle |
|------------|-------|---------|-------|--------|--------|
| `modal-dunning-send` | Mahnung senden | Action „Mahnung auslösen" Einzel ODER Bulk-Sammelaktion Cockpit | 420px Confirm | Empfänger-Liste · empfohlene Stufe · Ton-Preview · neue Frist · Doppel-Confirm bei Bulk + Disputed-Warning | §3.3 |

**Modal-Doppel-Confirm:** Bei Bulk-Versand mit ≥ 1 disputed Invoice darunter → zusätzliche Checkbox "Ich bestätige, dass ich die Honorarstreit-Pause bewusst überschreibe" + Audit-Log-Eintrag.

---

## 5. Permission-Matrix (4 Rollen × 11 Routen)

Übernommen aus `ARK_BILLING_PLAN_v0_1.md` §7 + `ARK_BILLING_INTERACTIONS_v0_1.md` §1.1.

### 5.1 Rollen-Übersicht

| Rolle | Routes | Edit | Special |
|-------|--------|------|---------|
| **Backoffice (BO)** | Alle 11 Routes | Full Edit · Approve bis Rabatt ≤ 20 % · Bulk-Aktionen | Bank-Import · Treuhand-Export · MwSt-Prepare |
| **GF / Admin** | Alle 11 Routes | Full Edit + Storno + Refund + Gutschrift + Inkasso-Übergabe + MwSt-Lock | Reports · Audit-Log · Override-Befugnis (3-Tage-Pflicht-Override · Rabatt > 20 %) |
| **AM** | `/billing` (KPIs eigene Mandate) · `/billing/rechnungen` · `/billing/debitoren` · `/billing/debitoren/:id` (RLS) | Read+Comment auf eigene Mandate · keine Edit-Rechte | — |
| **Treuhand (RO)** | `/billing` (RO-KPIs MwSt) · `/billing/mwst` · `/billing/export/treuhand` | Read-Only | externer Login · separater Auth-Flow · X-API-Key oder SSO |

### 5.2 Route-Permission-Matrix

| Route | BO | GF | AM | Treuhand |
|-------|----|----|----|----------|
| `/billing` | ✓ Full | ✓ Full | ✓ RLS-KPIs (eigene Mandate) | ✓ RO (nur MwSt-KPI) |
| `/billing/rechnungen` | ✓ Full | ✓ Full | ✓ RLS-Liste | – |
| `/billing/rechnungen/:id` | ✓ Edit (Draft) · Approve (≤ 20 %) | ✓ Edit + Approve + Storno + Issue | ✓ RO + Comment | – |
| `/billing/mahnwesen` | ✓ Full | ✓ Full | – | – |
| `/billing/debitoren` | ✓ Full | ✓ Full | ✓ RLS-Liste | – |
| `/billing/debitoren/:id` | ✓ Full | ✓ Full | ✓ RO eigene | – |
| `/billing/zahlungen` | ✓ Full · Bank-Import | ✓ Full | – | – |
| `/billing/refunds` | ✓ Cockpit-Lesen · Refund-Drawer öffnen | ✓ Full · Issue + Approve + Pay-Out | – | – |
| `/billing/mwst` | ✓ Prepare | ✓ Lock + Submit | – | ✓ RO |
| `/billing/inkasso` | ✓ Liste · Dossier-Export | ✓ Full · Übergabe | – | – |
| `/billing/export/treuhand` | ✓ Generate · History | ✓ Full | – | ✓ RO + Download |

### 5.3 Aktion-Permission-Matrix (Top-10 kritische Aktionen)

| Aktion | BO | GF | AM | Treuhand |
|--------|----|----|----|----------|
| Rechnung Draft erstellen | ✓ | ✓ | – | – |
| Rechnung Approve | ✓ (Rabatt ≤ 20 %) | ✓ | – | – |
| Rechnung Issue | ✓ | ✓ | – | – |
| Mahnung Stufe 1/2/3 senden | ✓ | ✓ | – | – |
| Storno | – | **✓ (immer GF)** | – | – |
| Gutschrift | – | **✓ (immer GF)** | – | – |
| Refund issuen | – | **✓ (immer GF)** | – | – |
| Inkasso-Übergabe | – | **✓ (immer GF)** | – | – |
| Bank-Import (CAMT.054) | ✓ | ✓ | – | – |
| MwSt-Quartal locken | – | **✓ (immer GF)** | – | – |
| Treuhand-Export generieren | ✓ | ✓ | – | ✓ RO-Download |
| Audit-Log einsehen | ✓ | ✓ | – | ✓ RO |

**RLS-Hinweis:** AM-Filter wirkt server-side über PostgreSQL-RLS-Policies (`fact_invoice.mandate_id` IN owned-mandates). Keine UI-only-Filter — Backend prüft jede Anfrage.

---

## 6. Apply-Reihenfolge + Dependencies

### 6.1 Apply-Reihenfolge

1. **DB-Patch v1.4 → v1.5** (`specs/ARK_DATABASE_SCHEMA_PATCH_v1_4_to_v1_5_billing.md`) — alle Tabellen + Adress-Erweiterung
2. **Stammdaten-Patch v1.4 → v1.5** (`specs/ARK_STAMMDATEN_PATCH_v1_4_to_v1_5_billing.md`) — §91 Billing-Stammdaten + Seeds
3. **Backend-Patch v2.6 → v2.7** (`specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_6_to_v2_7_billing.md`) — Events / Worker / Sagas / Endpoints
4. **Frontend-Patch v1.13 → v1.14 (dieser Patch)** — §4i Operations · Billing
5. **Gesamtsystem-Patch v1.5 → v1.6** (`specs/ARK_GESAMTSYSTEM_PATCH_v1_5_to_v1_6_billing.md`) — Changelog

### 6.2 Dependencies-Check

| Voraussetzung | Quelle | Status |
|---------------|--------|--------|
| `dim_accounts.legal_*`-Adress-Felder | DB-Patch v1.5 | Pflicht für QR-Bill-Validator |
| `fact_invoice` + `fact_invoice_item` Tabellen | DB-Patch v1.5 | Pflicht für Rechnungs-Liste |
| `dim_invoice_status` + `dim_invoice_types` Stammdaten | Stammdaten-Patch v1.5 | Pflicht für Status-/Typ-Badges |
| `/api/v1/billing/*` Endpoints | Backend-Patch v2.7 | Pflicht für alle Routen |
| `billing-pdf-generator` Worker | Backend-Patch v2.7 | Pflicht für `drawer-invoice-detail` PDF-Tab |
| `bank-statement-import` Worker | Backend-Patch v2.7 | Pflicht für `drawer-bank-import` |
| Outlook-Token-Pattern | Phase-1-A-FE-Patch v1.14 | Pflicht für `billing-email-sender` (Mahnung-Versand-Modal) |
| Reminders-Vollansicht | bestehend | Pflicht für `dunning-cadence-check` Reminder-Rows |

---

## 7. Sync-Impact

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_FRONTEND_FREEZE_v1_13.md` | **dieser Patch** → v1.14 | §4i Operations · Billing (NEU) |
| `ARK_BACKEND_ARCHITECTURE_v2_7.md` | bereits v2.7 (Backend-Patch) | Endpoints-Ref |
| `ARK_DATABASE_SCHEMA_v1_5.md` | bereits v1.5 (DB-Patch) | Tabellen-Ref |
| `ARK_STAMMDATEN_EXPORT_v1_5.md` | bereits v1.5 (Stammdaten-Patch) | Status/Typ-Badges-Vocabulary |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | wird via P2 → v1.6 | Cross-Module-Integration + Changelog |
| `wiki/meta/spec-sync-regel.md` | Update | Sync-Matrix-Eintrag Billing-Patches 5/5 (vorher 3/5) |
| `wiki/meta/mockup-baseline.md` | Update §16 | UI-Label-Vocabulary aus Billing-Interactions §11 |

---

## 8. Kompatibilitäts-Notizen

### 8.1 Sidebar-Änderung (Gruppe 4)

Die Ergänzung „Finanzen" in Gruppe 4 erweitert die Operations-Sidebar um einen 6. Eintrag. Kein Breaking-Change — bestehende Einträge (Email & Kalender / Performance / HR / Zeit / E-Learning) bleiben unverändert. Sidebar-Präferenz (`collapsed/expanded`) in `localStorage` bleibt gültig.

### 8.2 Drawer-Default-Regel

Alle 10 Billing-Drawer halten 540px-Default. Einzige Ausnahme `modal-dunning-send` als 420px-Confirm-Modal — bewusst pro CLAUDE.md "Modale nur für kurze Confirms". Audit-Log dokumentiert Bulk-Versand explizit.

### 8.3 RLS-Pattern (neu vs. CRM 1.0)

AM-Filter via PostgreSQL-RLS ist **neu im ERP-Workspace** — bestehende CRM-Routen nutzen App-Layer-Filter. Mockup-Baseline §17 (NEU) dokumentiert das Pattern. Frontend zeigt RLS-Indikator-Chip in Header der Liste.

### 8.4 Treuhand-Read-Only-Modus

Externer Treuhand-Login ist **erste externe Rolle** im ARK-System (CRM hatte nur interne Rollen). Auth-Flow: SSO oder X-API-Key (separat von JWT-User-Auth). Read-Only-Modus per Banner + globaler Edit-Disable. Audit-Log aller Treuhand-Aktionen.

---

## 9. Acceptance Criteria

- [ ] §4i Operations · Billing in `ARK_FRONTEND_FREEZE_v1_14.md` appendet
- [ ] Sidebar-Eintrag „Finanzen" unter Gruppe 4 sichtbar mit 9 Sub-Einträgen
- [ ] Alle 11 Top-Level-Routen `/billing/*` erreichbar + URL-State-Sync funktional
- [ ] Browser-Back funktioniert für alle Filter-Kombinationen + Drawer-States
- [ ] 4-Spalten-KPI-Bar live mit WS oder Polling 60s aktualisiert
- [ ] Mahnstufen-Pipeline-Chart click-through auf gefilterte Cockpit-Liste
- [ ] Aging-Buckets als Pill-Badges in Rechnungs-Liste sichtbar
- [ ] Treuhand-Read-Only-Banner sichtbar bei Login als Treuhand-Rolle
- [ ] AM-RLS-Filter-Chip in Liste-Header sichtbar + nicht entfernbar
- [ ] Mahnwesen-Cockpit zeigt 4-Spalten-Stufen mit Pause-Overlay bei disputed
- [ ] Alle 10 Drawer (`drawer-invoice-detail` … `drawer-mwst-quarter-close`) öffnen 540px slide-in von rechts
- [ ] `modal-dunning-send` öffnet 420px-Confirm mit Doppel-Confirm bei disputed
- [ ] Permission-Matrix korrekt: BO darf Rabatt ≤ 20 % approven, GF darüber, AM nur lesen, Treuhand RO
- [ ] PDF-Tab im `drawer-invoice-detail` rendert 3-Seiten-Preview (Anschreiben / Tabelle / Blind-Copy+QR)
- [ ] Stammdaten-Vocabulary aus `ARK_BILLING_INTERACTIONS_v0_1.md` §11 in allen Status-/Typ-Badges sichtbar (kein Enum-Code im UI)

---

## 10. Memory-Verweise

- `project_phase3_erp_standalone.md` — Billing als Phase-3-ERP-Modul (eigenständig, Bexio nur Export-Ziel)
- `feedback_phase3_modules_separate.md` — ERP-Module separat von CRM, eigene Hub-Pages
- `feedback_claude_design_no_app_bar.md` — Sub-Pages haben keine App-Bar (Hub-Topbar liefert das)
- `reference_treuhand_kunz.md` — Treuhand-Kunz Bexio-CSV + Swissdec-ELM
- `project_email_kalender_architecture.md` — Outlook-Token-Pattern für Mahnung-Versand
- `feedback_peter_explanations_not_renames.md` — Sidebar-Label „Finanzen" beibehalten (nicht „Billing")
- `project_guarantee_protection.md` — Refund-Cockpit logic (Garantie 3 Mt vs. Schutzfrist 12/16 Mt)

---

**Ende v1.14 · Billing.** Apply-Reihenfolge: DB v1.5 → Stammdaten v1.5 → Backend v2.7 → FE v1.14 (dieser Patch) → Gesamtsystem v1.6.
Mockup-Referenz: `mockups/ERP Tools/billing/*.html` (9 Mockups).
