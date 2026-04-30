---
title: "ARK Frontend Freeze Patch v1.13 → v1.14 · Phase-1-A Sync"
type: spec
module: stammdaten, email, powerbi
version: 1.14
created: 2026-04-30
updated: 2026-04-30
status: Erstentwurf · Phase-1-A Sync-Patch
sources: [
  "Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md",
  "specs/ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md",
  "specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md",
  "wiki/concepts/outlook-failsafe.md",
  "specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md",
  "specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_phase1a.md"
]
tags: [frontend, patch, stammdaten, email, powerbi, routing, sidebar, outbox, iframe, phase1a]
---

# ARK Frontend Freeze · Patch v1.13 → v1.14 · Phase-1-A Sync

**Stand:** 2026-04-30
**Status:** Erstentwurf · Phase-1-A Sync-Patch
**Quellen:**
- `Grundlagen MD/ARK_FRONTEND_FREEZE_v1_13.md` (Vorgänger · §6 Sidebar-Gruppierung · §7 Routenmodell)
- `specs/ARK_STAMMDATEN_VOLLANSICHT_SCHEMA_v0_1.md` (Layout + Route-Patterns)
- `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` §10/12 (State-Management + Sidebar-Integration)
- `wiki/concepts/outlook-failsafe.md` §3.6 (User-Surface · Outbox-Indicator)
- `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` §8 (Iframe-Embed-Flow)
- `specs/ARK_BACKEND_ARCHITECTURE_PATCH_v2_8_to_v2_9_phase1a.md` §3 (Embed-Token-Endpoint)

**Vorrang:** Stammdaten > Schema > Patch > Mockups

**Voraussetzungen:**
- DB-Patch v1.7 (`fact_email_send_queue`) deployed
- Backend-Patch v2.9 (Stammdaten-Endpoints + Email-Send-Worker + Embed-Token-Endpoint) deployed

---

## 0. ZIELBILD (was ändert dieser Patch)

Dieser Patch ergänzt Frontend Freeze v1.13 um drei UI-Blöcke aus Phase-1-A:

1. **Route `/stammdaten`**: 4 Route-Patterns, Sidebar-Eintrag „Stammdaten" unter Gruppe 3 (System), 8 Kategorie-Slugs, Permission-Regeln.
2. **Email-Outbox-Indicator**: Header-Badge für ausstehende/fehlgeschlagene Mails, Mini-Drawer, Dead-Letter-Banner — gebaut auf `fact_email_send_queue`.
3. **Power-BI-Iframe-Tile-Pattern**: Rendering des Tile-Typs `iframe_powerbi` im Performance-Modul, Token-Lifecycle (60 min TTL, Auto-Refresh nach 50 min), Loading- und Error-States.

---

## 1. Route `/stammdaten` (Stammdaten-Vollansicht)

### 1.1 Routenmodell-Ergänzung

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_13.md` §7 Routenmodell:

```text
-- Bestehend (v1.13):
/settings · /admin

-- NEU (v1.14):
/stammdaten
/stammdaten/:category
/stammdaten/:category/:catalog
/stammdaten/:category/:catalog/:entry
```

**Erläuterung der 4 Route-Patterns:**

| Route | Bedeutung | UI-State |
|-------|-----------|----------|
| `/stammdaten` | Einstiegsseite · Tab 1 (Workflow) aktiv · Stat-Strip + Card-Grid | Default-View |
| `/stammdaten/:category` | Kategorie-Tab aktiv (z.B. `/stammdaten/communication`) | Tab gewechselt |
| `/stammdaten/:category/:catalog` | Kategorie + Drill-Down (Slide-In) geöffnet | Drill-Down-Pane sichtbar |
| `/stammdaten/:category/:catalog/:entry` | Drill-Down + Detail-Drawer geöffnet | 2-Layer-UI aktiv |

**:category-Slugs (8 gültige Werte):**

```text
workflow              → Tab 1: Prozess-Stages, Activity-Types, Reminder-Types, ...
communication         → Tab 2: Activity-Types (Kommunikation), Reminder-Templates, ...
skills                → Tab 3: Skills, EQ-Dimensionen, Motivatoren, ...
branchen-geo          → Tab 4: Branchen, Regionen, Kantone, BKP-Nummern, ...
mitarbeiter-account   → Tab 5: Org-Funktionen, Sparten, Mitarbeiter-Kürzel, ...
mandat-honorar-assessment → Tab 6: Mandat-Typen, Honorar-Settings, Assessment-Typen, ...
system-scraper        → Tab 7: Scraper-Typen, Global-Settings, ...
governance            → Tab 8: Audit-Kategorien, DSGVO-Kategorien, ...
```

**URL-State-Sync** (analog zu `specs/ARK_STAMMDATEN_VOLLANSICHT_INTERACTIONS_v0_1.md` §10.1):

```text
?tab=<slug>                        → aktive Kategorie (redundant wenn :category in Pfad)
?active=true|false                 → Filter-Chip „Aktiv/Inaktiv"
?missing_translation=true          → Filter-Chip „Übersetzung fehlt"
?top10=true                        → Filter-Chip „Top 10 Verwendung"
?modified_7d=true                  → Filter-Chip „Letzte 7 Tage"
?sort=label_de:asc|code:asc        → Drill-Down-Sortierung
?search=<urlencoded>               → Globale-Suche-Pre-Fill
?drawer-tab=usage|history|translations → aktiver Detail-Drawer-Tab
?mode=edit                         → Edit-Modus (Admin-only · Fallback browse für non-Admin)
```

### 1.2 Sidebar-Eintrag

Ergänzung zu `ARK_FRONTEND_FREEZE_v1_13.md` §6 Sidebar-Gruppierung:

```text
-- Bestehend (v1.13):
GRUPPE 3 – System:
  Admin │ Settings

-- NEU (v1.14):
GRUPPE 3 – System:
  Admin │ Settings │ Stammdaten
```

**Details zum Sidebar-Eintrag „Stammdaten":**

```typescript
{
  label: 'Stammdaten',
  href: '/stammdaten',
  icon: 'Database',       // Lucide-Icon (analog bestehende System-Icons)
  group: 3,               // System-Gruppe
  permission: 'all',      // Alle Rollen können Stammdaten lesen
  activePattern: /^\/stammdaten/,  // aktiv bei allen Sub-Routes
  badge: null,            // kein Count-Badge (kein operativer Status)
}
```

**Permission-Verhalten:**
- Alle Rollen: Zugriff auf `/stammdaten` (Browse-Modus)
- Admin: Edit-Modus via `?mode=edit`-Toggle verfügbar
- Non-Admin + `?mode=edit` im URL: Redirect auf `/stammdaten` (ohne mode-param) + Toast „Edit-Modus erfordert Admin-Rolle"

### 1.3 Vollseite vs. Drawer

**Entscheidung:** `/stammdaten` ist eine **Vollseite** (analog `/admin`, `/settings`).
- Kein Slide-In vom Dashboard oder anderen Seiten
- Browser-Back funktioniert für alle 4 Route-Levels (URL-State-Sync als Single-Source-of-Truth)
- Drill-Down und Detail-Drawer sind **interne Layer** innerhalb der Stammdaten-Vollseite (760px Slide-In von rechts, nicht globaler Drawer)

**Ausnahme:** `Ctrl+Click` auf Stammdaten-Wert in anderen Mockups (z.B. Stage-Pill) öffnet `/stammdaten/:category/:catalog/:entry` in neuem Tab (kein Drawer-Cross-Route).

### 1.4 Komponent-Struktur (Next.js App Router)

```text
app/
  stammdaten/
    page.tsx                          → Stammdaten-Root (Tab 1 default)
    [category]/
      page.tsx                        → Kategorie-Tab aktiv
      [catalog]/
        page.tsx                      → Drill-Down geöffnet
        [entry]/
          page.tsx                    → Detail-Drawer geöffnet
```

**Shared Layout** (`app/stammdaten/layout.tsx`):
- Stammdaten-Header (Title + Globale Suche + Edit-Modus-Toggle + CSV-Export-Dropdown)
- Tabbar (8 Kategorien · sticky)
- Stat-Strip + Filter-Chips (unter Tabbar · re-render bei Tab-Wechsel)

### 1.5 Keyboard-Shortcuts (global für `/stammdaten`)

```text
Ctrl+K (Cmd+K Mac)        → Globale Suche öffnen (modale Command-Palette)
Ctrl+E (Admin only)        → Edit-Modus toggle (mit Confirm)
Ctrl+Shift+E              → CSV-Export-Dropdown
1–8                        → Tab-Switch (1=Workflow, ..., 8=Governance)
?                          → Keyboard-Help-Overlay
Esc                        → Drill-Down schließen (oder Detail-Drawer wenn drüber)
```

---

## 2. Email-Outbox-Indicator (Outlook-Failsafe-UI)

Implementierungs-Referenz: `wiki/concepts/outlook-failsafe.md` §3.6

### 2.1 Outbox-Indicator im Header

Ergänzung zur Top-Bar (bestehend: Notifications-Bell + Reminder-Zähler + User-Menü):

```text
-- Bestehend (v1.13):
Top-Bar-Right:  [Cmd+K] [Bell N] [Reminder N] [User-Menü]

-- NEU (v1.14):
Top-Bar-Right:  [Cmd+K] [Outbox N] [Bell N] [Reminder N] [User-Menü]
```

**Outbox-Badge-Logik:**

```typescript
// Query (TanStack Query, Polling 30s):
// GET /api/v1/email-queue/my-status
// Response: { pending: N, sending: N, failed: N, dead_lettered: N }

const outboxCount = pending + sending + failed;
// dead_lettered: separates Dead-Letter-Banner (nicht im Outbox-Count)

// Badge-Rendering:
// - outboxCount === 0: kein Badge sichtbar (Icon nur als Ghost)
// - outboxCount > 0: Badge mit Count + Amber-Farbe (warning)
// - failed > 0 (ohne dead_lettered): Badge Amber + Pulse-Animation
// - dead_lettered > 0: Dead-Letter-Banner (siehe §2.3), Badge Rot
```

**Icon:** `Send` (Lucide) — analog Notifications-Bell (kein Text-Label in collapsed Sidebar)

### 2.2 Outbox-Mini-Drawer

Click auf Outbox-Badge → Mini-Drawer öffnet (540px · rechts · über aktuellem Content):

```text
┌─────────────────────────────────────────────────┐
│  Ausgehende Mails                          [X]  │
│  ─────────────────────────────────────────────  │
│  [Tab: Ausstehend (N)] [Tab: Fehlgeschlagen (M)] │
│  ─────────────────────────────────────────────  │
│  Mail-Row:                                       │
│  [Icon] An: peter@firma.ch · Betreff: Einladung  │
│          Status: ⏳ Wird gesendet               │
│          Gesendet: vor 2 min                     │
│  ─────                                           │
│  Mail-Row:                                       │
│  [Icon] An: kunde@ag.ch · Betreff: Follow-Up     │
│          Status: ⚠ Fehler (3/5 Versuche)         │
│          Nächster Versuch: in 8 min              │
│          [Jetzt erneut versuchen]                │
│  ─────────────────────────────────────────────  │
│  [Alle als gelesen markieren]                    │
└─────────────────────────────────────────────────┘
```

**Drawer-Inhalt:**

| Element | Daten-Quelle | Verhalten |
|---------|--------------|-----------|
| Tab „Ausstehend" | `status IN ('pending', 'sending')` | Live-Update via WS-Push (`email.send.queued` / `email.send.sent`) |
| Tab „Fehlgeschlagen" | `status = 'failed'` | Zeigt Fehler-Klasse + nächsten Retry-Zeitpunkt |
| „Jetzt erneut versuchen" Button | PATCH `/api/v1/email-queue/:id/retry` | Setzt `next_retry_at = now()` (Admin + eigene Mails) |
| Status-Icon | `email_send_status`-Enum | ⏳ pending/sending · ⚠ failed · ✅ sent |

**Leerer Zustand:** „Keine ausstehenden Mails. Alle Mails wurden zugestellt."

### 2.3 Dead-Letter-Banner

Trigger: `dead_lettered > 0` in `/api/v1/email-queue/my-status`

```text
┌─────────────────────────────────────────────────────────────────┐
│  ⛔  N Mails konnten nicht zugestellt werden  [Details]  [×]   │
└─────────────────────────────────────────────────────────────────┘
```

**Banner-Eigenschaften:**
- Farbe: `var(--color-danger)` (#ef4444) · Hintergrund: danger/10
- Position: Banner-Zone (unter Top-Bar, über Hauptcontent — analog Offline-Banner)
- Sticky: bleibt sichtbar bis explizit geschlossen (`[×]`) oder alle DL-Jobs verworfen/retried
- Click „Details" → Outbox-Mini-Drawer öffnet mit Tab „Fehlgeschlagen" gefiltert auf `dead_lettered`

**Dead-Letter-Drawer (Tab „Fehlgeschlagen" für dead_lettered):**

```text
Mail-Row:
[Icon] An: ku@firma.ch · Betreff: Nachfass
        Status: ⛔ Dauerhaft fehlgeschlagen
        Fehler: Token abgelaufen (Outlook-Verbindung)
        [Erneut versuchen]  [Bearbeiten]  [Verwerfen]
```

Aktionen:
- **Erneut versuchen** (nur wenn `last_error_code = 'MSGRAPH_TOKEN_EXPIRED'` und Token jetzt frisch): PATCH reset → pending
- **Bearbeiten**: öffnet Compose-Drawer mit vorausgefülltem Inhalt (neue Queue-Entry)
- **Verwerfen**: DELETE `/api/v1/email-queue/:id` + Bestätigungs-Modal „Mail permanent löschen?"

### 2.4 Compose-Drawer-Integration

Ergänzung zum bestehenden Compose-Drawer-Pattern (Email-Kalender-Spec):

```text
-- Bestehend (v1.13): Click „Senden" → direkt MS-Graph-Call → Spinner → Success/Error-Toast

-- NEU (v1.14): Click „Senden"
  1. INSERT in fact_email_send_queue (via POST /api/v1/email-queue)
  2. emit email.send.queued
  3. Drawer schließt sofort (kein Spinner-Block)
  4. Toast: „Mail in Queue · wird in Kürze zugestellt" (autodismiss 3s)
  5. Outbox-Badge erscheint/aktualisiert sich (via WS-Push)
```

**Vorteil:** User kann sofort weiterarbeiten, kein blockierender Spinner bei langsamer MS-Graph-Verbindung.

### 2.5 Polling-Strategie

```typescript
// TanStack Query — Polling für Outbox-Status
useQuery({
  queryKey: ['email-queue-status'],
  queryFn: () => fetch('/api/v1/email-queue/my-status').then(r => r.json()),
  refetchInterval: 30_000,              // alle 30s
  refetchIntervalInBackground: false,   // kein Polling wenn Tab nicht aktiv
  staleTime: 25_000,                    // 25s fresh (verhindert Doppel-Fetch)
});

// WS-Push (zusätzlich, für Echtzeit-Updates):
// Channel: user:<user_id> (bestehender WS-Channel)
// Events: email.send.queued · email.send.sent · email.send.failed · email.send.dead_lettered
// → invalidateQuery(['email-queue-status']) bei jedem dieser Events
```

---

## 3. Power-BI-Iframe-Tile-Pattern (Performance-Modul)

Implementierungs-Referenz: `specs/ARK_POWER_BI_INTEGRATION_PLAN_v0_1.md` §8

### 3.1 Tile-Type `iframe_powerbi`

Ergänzung zum bestehenden Dashboard-Tile-System (Performance-Modul, Scope v1.13 TEIL Q):

**Tile-Konfiguration (aus `dim_dashboard_tile_type`):**

```typescript
interface PowerBiTileConfig {
  tile_type: 'iframe_powerbi';
  report_id: string;       // Power-BI Report-UUID
  page_name?: string;      // Optional: spezifische Report-Page
  aspect_ratio?: '16:9' | '4:3' | 'full';  // default: '16:9'
  show_toolbar?: boolean;  // default: false (clean embed)
}
```

### 3.2 Token-Lifecycle (Frontend-seitig)

```typescript
// Component: PowerBiTile.tsx
function PowerBiTile({ config }: { config: PowerBiTileConfig }) {
  const [embedState, setEmbedState] = useState<'loading' | 'ready' | 'refreshing' | 'error'>('loading');
  const [embedData, setEmbedData] = useState<EmbedTokenResponse | null>(null);
  const refreshTimerRef = useRef<ReturnType<typeof setTimeout>>();

  // Initialer Token-Fetch
  const fetchToken = useCallback(async () => {
    setEmbedState(prev => prev === 'ready' ? 'refreshing' : 'loading');
    try {
      const data = await fetch('/api/v1/performance/powerbi/embed-token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ report_id: config.report_id, page_name: config.page_name }),
      }).then(r => r.json());

      setEmbedData(data);
      setEmbedState('ready');

      // Auto-Refresh nach refresh_after_seconds (default: 3000s = 50 min)
      refreshTimerRef.current = setTimeout(fetchToken, data.refresh_after_seconds * 1000);
    } catch (err) {
      setEmbedState('error');
    }
  }, [config.report_id, config.page_name]);

  useEffect(() => {
    fetchToken();
    return () => {
      if (refreshTimerRef.current) clearTimeout(refreshTimerRef.current);
    };
  }, [fetchToken]);

  // ...rendering (siehe §3.3 und §3.4)
}
```

**Token-TTL: 60 Minuten (Power-BI-Default)**
**Auto-Refresh: nach 50 Minuten** (10-Minuten-Puffer vor Ablauf, verhindert Iframe-Unterbrechung)

<!-- NEEDS-USER-INPUT: Soll der Token-Refresh via Polling (setTimeout, wie oben) ODER via WebSocket-Push vom Backend ausgelöst werden? Polling ist einfacher (kein Backend-Push-Logik), WS-Push ist präziser (Backend kennt exakten Ablaufzeitpunkt). Für Phase-1 empfohlen: Polling (setTimeout). -->

### 3.3 Loading-State

```tsx
// Während Token-Fetch (initial + refresh)
if (embedState === 'loading') {
  return (
    <div className="powerbi-tile powerbi-tile--loading">
      <div className="tile-spinner">
        <Loader2 className="animate-spin" size={32} />
      </div>
      <p className="tile-loading-label">Power-BI-Report wird geladen…</p>
    </div>
  );
}

// Bei Token-Refresh (Tile bleibt sichtbar, diskreter Hinweis)
if (embedState === 'refreshing') {
  return (
    <>
      {/* Bestehender Iframe weiterhin sichtbar */}
      <PowerBiIframe embedData={embedData!} config={config} />
      <div className="powerbi-refresh-overlay">
        <RefreshCw className="animate-spin" size={16} />
        <span>Wird aktualisiert…</span>
      </div>
    </>
  );
}
```

### 3.4 Error-State

```tsx
if (embedState === 'error') {
  return (
    <div className="powerbi-tile powerbi-tile--error">
      <AlertTriangle size={32} className="text-danger" />
      <p className="tile-error-title">Power-BI-Report nicht verfügbar</p>
      <p className="tile-error-detail">
        Der Report konnte nicht geladen werden.
        Bitte versuche es erneut oder kontaktiere den Administrator.
      </p>
      <Button variant="outline" size="sm" onClick={fetchToken}>
        <RefreshCw size={14} />
        Erneut versuchen
      </Button>
    </div>
  );
}
```

**Error-Szenarien:**

| HTTP-Status | Ursache | UI-Meldung |
|-------------|---------|------------|
| 503 | Power-BI-Service nicht erreichbar | „Power-BI-Service derzeit nicht verfügbar · bitte später erneut versuchen" |
| 404 | Report-ID ungültig | „Report nicht gefunden · Admin informieren" |
| 403 | Azure-AD-App nicht konfiguriert | „Power-BI nicht eingerichtet · Admin-Setup erforderlich" (nur für Admin sichtbar mit Link zu `/admin`) |

### 3.5 Ready-State (Iframe-Rendering)

```tsx
function PowerBiIframe({ embedData, config }: { embedData: EmbedTokenResponse; config: PowerBiTileConfig }) {
  // Embed-URL mit Token im Fragment (Power-BI-Embed-Standard)
  const iframeSrc = `${embedData.report_url}&autoAuth=false&ctid=<tenant>&navContentPaneEnabled=false&toolbarEnabled=${config.show_toolbar ?? false}#access_token=${embedData.embed_token}`;

  return (
    <iframe
      src={iframeSrc}
      className="powerbi-iframe"
      style={{
        width: '100%',
        aspectRatio: config.aspect_ratio ?? '16/9',
        border: 'none',
        borderRadius: 'var(--radius)',
      }}
      title="Power-BI-Report"
      sandbox="allow-scripts allow-same-origin allow-forms allow-popups"
      loading="lazy"
    />
  );
}
```

**Sandbox-Attribute:** `allow-scripts allow-same-origin allow-forms allow-popups` — Minimum-Set für Power-BI-JS-SDK im Iframe.

### 3.6 Tile-Slot-Integration im Performance-Dashboard

Der Tile-Type `iframe_powerbi` ist ein Rendering-Typ im bestehenden Dashboard-Tile-System (Performance-Modul TEIL Q, v1.13):

```typescript
// In DashboardTile.tsx — Rendering-Switch ergänzen:
switch (tile.tile_type) {
  // ... bestehende Tile-Types
  case 'iframe_powerbi':
    return <PowerBiTile config={tile.config as PowerBiTileConfig} />;
}
```

**Tile-Größe:** Power-BI-Tiles belegen standardmäßig 2 Spalten im Grid (breiter als Standard-KPI-Tiles).
**Admin-Only-Placement:** Power-BI-Tiles können nur von Admin in das Dashboard gesetzt werden (analog locked tiles).

---

## 4. SYNC-IMPACT

| Grundlagen-Datei | Änderung | Grund |
|------------------|----------|-------|
| `ARK_BACKEND_ARCHITECTURE_v2_8.md` | Backend-Patch v2.9 **Voraussetzung** | Stammdaten-Endpoints + Email-Send-Worker + Embed-Token |
| `ARK_DATABASE_SCHEMA_v1_6.md` | DB-Patch v1.7 **Voraussetzung** | `fact_email_send_queue` |
| `ARK_STAMMDATEN_EXPORT_v1_6.md` | Kein Patch nötig | Keine neuen Stammdaten |
| `ARK_GESAMTSYSTEM_UEBERSICHT_v1_5.md` | Changelog-Eintrag Phase-1-A | Stammdaten-Route + Outbox + Power-BI-Embed |

---

## 5. Kompatibilitäts-Notizen

### 5.1 Sidebar-Änderung (Gruppe 3)

Die Ergänzung von „Stammdaten" in Gruppe 3 erweitert die Sidebar um einen Eintrag. Kein Breaking-Change — bestehende `Admin`- und `Settings`-Einträge bleiben unverändert. Sidebar-Präferenz (`collapsed/expanded`) in `localStorage` bleibt gültig.

### 5.2 Top-Bar-Änderung (Outbox-Indicator)

Der Outbox-Indicator ist ein optionaler Baustein — er ist nur sichtbar wenn `outboxCount > 0`. Im Default-Zustand (keine ausstehenden Mails) bleibt die Top-Bar visuell unverändert. Das Icon ist als Ghost-Icon vorhanden (kein Badge), um konsistentes Layout zu gewährleisten.

### 5.3 Performance-Modul-Erweiterung (Power-BI-Tile)

`PowerBiTile` ist ein neuer Tile-Type im bestehenden Tile-Rendering-Switch. Keine Änderungen an bestehenden Tile-Types. Bestehende Dashboards ohne `iframe_powerbi`-Tiles sind nicht betroffen.

---

## 6. Acceptance Criteria

- [ ] Route `/stammdaten` erreichbar + Sidebar-Eintrag unter Gruppe 3 aktiv
- [ ] Alle 4 Route-Patterns (`/stammdaten`, `/:category`, `/:category/:catalog`, `/:category/:catalog/:entry`) funktional + URL-State-Sync
- [ ] 8 Kategorie-Slugs routbar, ungültige Slugs → 404-Fallback
- [ ] Edit-Modus via `?mode=edit` für Admin aktivierbar, 403-Redirect für non-Admin
- [ ] Outbox-Badge erscheint wenn `pending + sending + failed > 0`
- [ ] Outbox-Mini-Drawer öffnet via Badge-Click mit Status-Liste + Manual-Retry
- [ ] Dead-Letter-Banner erscheint wenn `dead_lettered > 0`
- [ ] Compose-Drawer: Click „Senden" → sofortiger Close + Toast „Mail in Queue"
- [ ] `PowerBiTile`: Loading-State während Token-Fetch sichtbar
- [ ] `PowerBiTile`: Iframe rendert mit korrektem Embed-Token nach Token-Fetch
- [ ] `PowerBiTile`: Token-Auto-Refresh nach 50 min (ohne Unterbrechung des Iframes)
- [ ] `PowerBiTile`: Error-State mit „Erneut versuchen"-Button bei 503/404/403

---

**Ende v1.14.** Apply-Reihenfolge: DB-Patch v1.7 → Backend-Patch v2.9 → dieses FE-Patch v1.14.
Mockup-Referenz für Stammdaten-Vollansicht: `mockups/Vollansichten/stammdaten.html`.
