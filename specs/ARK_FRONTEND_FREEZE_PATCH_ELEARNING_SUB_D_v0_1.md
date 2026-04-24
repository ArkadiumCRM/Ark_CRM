# ARK CRM — Frontend-Freeze-Patch · E-Learning Sub D · v0.1

**Scope:** Frontend-Erweiterung für den Progress-Gate (Sub D): Gate-Page, Compliance-Dashboards, Login-Popup, Topbar-Badge, Dashboard-Banner, Rules-Editor.
**Zielversion:** Frontend-Freeze v1.11 (gemeinsam mit Sub A/B/C).
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_D_SCHEMA_v0_1.md`, `specs/ARK_E_LEARNING_SUB_D_INTERACTIONS_v0_1.md`.
**Vorherige Patches:** Sub A + B + C Frontend-Patches.
**Stand:** 2026-04-20
**Status:** Review ausstehend (Peter)

---

## Changelog

| # | Bereich | Änderung |
|---|---------|----------|
| 1 | Pages | +5 neue (gate, compliance-admin, compliance-team, gate-rules, gate-overrides, gate-audit) |
| 2 | Global Components | Login-Popup, Topbar-Badge, Dashboard-Banner — injected in CRM + ERP |
| 3 | Frontend-Middleware | HTTP-Interceptor fängt `403 GATE_BLOCKED` → Redirect |
| 4 | Sidebar | MA-Block + Admin/Head-Block erweitert |
| 5 | Rules-Editor-UX | Drag-Drop-Priority, Preview-Dry-Run |

---

## 1. Pages

Pfad: `mockups/erp/elearn/`. Baseline-Styling = CRM.

### 1.1 `erp/elearn/gate.html` — Full-Screen Gate (MA)

**Route:** `/erp/elearn/gate.html?rules=<id,id,...>&trigger_feature=<key>`

**Layout:**

```
┌────────────────────────────────────────────────┐
│                                                │
│   🔒                                           │
│                                                │
│   Zugriff gesperrt                             │
│                                                │
│   Du hast offene Pflicht-Aufgaben, die du      │
│   erledigen musst, bevor du weiterarbeiten     │
│   kannst.                                      │
│                                                │
│   Offene Items:                                │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │ 📬 Newsletter KW17 — Quiz offen        │  │
│   │ [Jetzt bearbeiten →]                   │  │
│   └────────────────────────────────────────┘  │
│                                                │
│   ┌────────────────────────────────────────┐  │
│   │ 📚 Onboarding-Kurs "Marktwissen ARC"   │  │
│   │ [Weiterlernen →]                        │  │
│   └────────────────────────────────────────┘  │
│                                                │
│   Bei Fragen wende dich an deinen Head-of      │
│   (Name wird dynamisch angezeigt).             │
│                                                │
└────────────────────────────────────────────────┘
```

- Hintergrund leicht abgedunkelt, Zentral-Content max 640 px.
- Kein Sidebar / keine Topbar sichtbar (kompletter Lockdown).
- Button „Logout" unten rechts (falls Override nötig → Head ruft MA).

### 1.2 `erp/elearn/admin/compliance.html` — Admin-Dashboard

**KPI-Top-Row:**
- Tenant-Avg Compliance-Score (grosse Zahl + Trend-Pfeil)
- % MA über 80 %
- % MA unter 50 %
- Total Overdue Items

**Widgets:**
- Trend-Chart 6 Monate (Linie: Durchschnitts-Score).
- Team-Tabelle: Sparte, Team-Size, Avg-Score, Worst-Score, Overdue-Count.
- MA-Tabelle (sortierbar, filterbar):
  - Name, Team, Sparte, Score, Overdue-Items, Active-Overrides, Last-Activity.
  - Zeile → Drawer 540 px mit:
    - Pending-Items-Liste (click-through zu Kurs/Newsletter).
    - Active-Overrides (mit End-Button).
    - History (letzte 30 Tage Gate-Events).
    - Action: „Override setzen", „Compliance-Report exportieren".

**Export:** CSV/XLSX-Button oben rechts.

### 1.3 `erp/elearn/team/compliance.html` — Head-Dashboard

Gleiches Layout wie Admin, aber:
- Sparten-Filter auf eigenes Team gelockt.
- MA-Tabelle nur Team-Members.
- Kein Rules-Editor-Link.

### 1.4 `erp/elearn/admin/gate-rules.html`

**Tabelle:**
- Name, Trigger, Blocked-Features-Count, Priority, Enabled-Toggle.
- Drag-Drop-Reorder für Priority (auto-save).

**`+ Neue Rule`-Drawer:**
```
Name:                 [text]
Description:          [textarea]
Trigger-Type:         [dropdown] (newsletter_overdue | onboarding_overdue | ...)
Trigger-Params:       [dynamisch je nach Type]
  - newsletter_overdue: Enforcement-Mode (soft|hard)
  - onboarding_overdue: Days-Past-Deadline
  - refresher_due: Course-Slugs (Multi-Select, optional)
  - cert_expired: Course-Slugs (Multi-Select, optional)

Blocked Features:     [Multi-Select aus FEATURE_CATALOG]
Allowed Features:     [Multi-Select]
Priority:             [number]
Enabled:              [toggle]

Preview:
  "Diese Rule wird aktuell X MA blockieren"
  (Dry-Run via /api/elearn/admin/gate/rules/preview)

[Speichern]  [Abbrechen]
```

### 1.5 `erp/elearn/admin/gate-overrides.html`

**Tabelle:**
- MA, Type, Reason, Valid-From, Valid-Until, Status (aktiv/beendet), Created-By.
- Filter: Type, Status, MA, Zeitraum.

**`+ Neuer Override`-Drawer:**
```
MA:             [autocomplete]
Type:           [radio] vacation | parental_leave | medical | emergency_bypass | other
Reason:         [textarea, Pflicht]
Valid-From:     [datetime] (Default NOW)
Valid-Until:    [datetime, optional — leer = offen]
Pause-Deadlines: [toggle, Default: true]

[Speichern]  [Abbrechen]
```

### 1.6 `erp/elearn/admin/gate-audit.html`

**Tabelle aller Gate-Events:**
- Timestamp, MA, Feature, Action, Rule-Name, Override-Ref.
- Filter: MA, Feature, Action, Zeitraum, Rule.
- Zeile → Drawer mit Request-Meta-Details (Pfad, Methode, User-Agent).
- Export CSV.

## 2. Global Components (in bestehende Pages injected)

### 2.1 Login-Popup

**Nach erfolgreichem Login, vor erstem Page-Render:**

```ts
// Pseudocode:
const { pending_items, blocks_active } = await fetch('/api/elearn/my/gate-status');
if (pending_items >= settings.login_popup_min_items) {
  showModal({
    title: "Offene Pflicht-Aufgaben",
    items: rules_triggered,
    button_primary: "Zu meinen Aufgaben" → '/erp/elearn/dashboard.html',
    button_secondary: "Später" (disabled wenn blocks_active)
  });
}
```

**Popup-Design:** 540 px width, hell modaler Overlay.

### 2.2 Topbar-Badge

**Icon:** Checkliste mit Count-Badge (rot bei Pflicht, orange bei Soft).

**Hover:** Mini-Popover mit Top-5 pending Items.

**Klick:** Navigation zu `/erp/elearn/dashboard.html` (MA) oder `/erp/elearn/admin/compliance.html` (Admin/Head).

**Conditional:** nur sichtbar wenn `pending_items > 0`.

### 2.3 Dashboard-Banner (im Sub-A-Dashboard)

Bereits in Sub-A-Frontend-Patch erwähnt, hier konkretisiert:

```
┌───────────────────────────────────────────────────┐
│  ⚠ 2 offene Pflicht-Aufgaben                     │
│  • Newsletter KW17 (2 Tage)                       │
│  • Onboarding "Marktwissen ARC" (überfällig!)    │
│                                                   │
│  [Details ansehen]         [Ausblenden (30 Min)]  │
└───────────────────────────────────────────────────┘
```

- Gelb bei Soft, rot bei Hard.
- „Ausblenden" snoozt für 30 Min (localStorage).
- Klickbar pro Item → direct navigation.

## 3. HTTP-Interceptor (Frontend)

**Globaler Axios/Fetch-Interceptor:**

```ts
interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 403 && error.response.data?.error === 'GATE_BLOCKED') {
      const { rule_id, redirect_to } = error.response.data;
      window.location.href = redirect_to; // → /erp/elearn/gate.html?rules=<id>
      return;
    }
    return Promise.reject(error);
  }
);
```

**Ausnahme:** eigene Gate-Status-Calls (`/api/elearn/my/gate-status`) fangen den Fehler selbst ab.

## 4. Sidebar-Erweiterung

**MA-Block:**

| Position | Label | Link |
|----------|-------|------|
| … | Meine Kurse | `dashboard.html` |
| … | Mein Newsletter | `newsletter.html` |
| … | **Mein Compliance-Status** | `my/compliance.html` |

**Head-Block (neu):**

| Position | Label | Link |
|----------|-------|------|
| … | Team-Übersicht | `team.html` |
| … | **Team-Compliance** | `team/compliance.html` |

**Admin-Block (bestehend → erweitert):**

| Position | Label | Link |
|----------|-------|------|
| … | … bestehende Admin-Items … | |
| — | — Trenner „Progress-Gate" — | — |
| … | **Compliance-Dashboard** | `admin/compliance.html` |
| … | **Gate-Rules** | `admin/gate-rules.html` |
| … | **Override-Verwaltung** | `admin/gate-overrides.html` |
| … | **Gate-Audit-Log** | `admin/gate-audit.html` |

## 5. Compliance-Widgets (MA-Seite)

**`erp/elearn/my/compliance.html`** (neu für MA-Self-View):

- Compliance-Score-Gauge (0-100 mit farbigem Ring).
- Trend-Chart 6 Monate.
- Pending-Items-Liste mit Deadline-Countdown.
- Cert-Liste (aktiv + abgelaufen).
- Active-Override-Info (falls vorhanden).

## 6. Keyboard-Shortcuts

### 6.1 Compliance-Dashboard (Admin/Head)

| Shortcut | Aktion |
|----------|--------|
| `F` | Filter-Bar öffnen |
| `E` | Export CSV |
| `J` / `K` | Next / Prev MA in Tabelle |

### 6.2 Gate-Rules-Editor

| Shortcut | Aktion |
|----------|--------|
| `N` | Neue Rule |
| `D` | Disable (auf selektierter Rule) |
| `E` | Edit |

### 6.3 Login-Popup

| Shortcut | Aktion |
|----------|--------|
| `Enter` | „Zu meinen Aufgaben" (primary) |
| `Esc` | „Später" (wenn enabled) |

## 7. Design-System-Konformität

- Echte Umlaute UTF-8.
- Drawer 540 px für CRUD.
- Datum-Picker nativ.
- Keine DB-Tech-Details in User-facing-Texten.
- Gate-Page darf Gate-Rule-Namen zeigen (Head-geschaffen, frei formulierbar) — aber keine Feature-Keys (technisch, `create_candidate` ist intern). Stattdessen dynamische deutsche Labels.
- Admin-Audit-Page darf Feature-Keys und Rule-Namen zeigen (Admin-Kontext, `<!-- ark-lint-skip:begin reason=admin-gate-audit -->`).

## 8. Responsive

- **Desktop:** volle Layouts.
- **Tablet:** Tabellen Horizontal-Scroll; Drawers Full-Width-Bottom.
- **Mobile:** Gate-Page + Login-Popup Mobile-optimiert (MA muss auch unterwegs den Block verstehen können).

## 9. A11y

- Gate-Page: `role="alertdialog"` mit ARIA-Describe auf pending Items.
- Login-Popup: Fokus-Trap, `aria-modal="true"`.
- Compliance-Score-Gauge: ARIA-Live bei Wert-Änderung.
- Farb-Codierung nicht alleiniger Info-Träger (Icons + Text redundant).

## 10. Wiki-Sync

- `wiki/meta/mockup-baseline.md` — ERP-Workspace-Abschnitt um Sub-D-Pages ergänzen.
- `wiki/concepts/elearning-module.md` — UI-Teil Sub D.
- `wiki/concepts/gate-enforcement.md` — neue Seite mit UI-Flow-Diagrammen.

## 11. Offene Punkte

- **Gate-Page-Customization:** Tenant kann Gate-Page-Text anpassen (Branding, Hinweise, Hilfe-Kontakt)? Phase-2-Setting.
- **Override-Request-Workflow:** MA beantragt Override, Head approved? MVP: nur Head/Admin legt direkt an. Phase-2 Request-Flow.
- **Mobile-App-Gate:** falls später Mobile-App, muss Gate-Middleware dort ebenfalls greifen (Client-Side-Check + Server-Side-403). Phase-3.
