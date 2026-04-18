---
title: "Design Tokens (Dark + Light Mode)"
type: concept
created: 2026-04-14
updated: 2026-04-14
sources: ["ARK_FRONTEND_FREEZE_v1_10.md", "ARK_KANDIDATENMASKE_SCHEMA_v1_3.md § 0"]
tags: [design, tokens, dark-mode, light-mode, theme, farben, frontend]
---

# Design Tokens (Dark + Light Mode)

ARK CRM unterstützt **Dark Mode (Default)** und **Light Mode** (user-umschaltbar). Alle Farb-Tokens sind als CSS-Variablen definiert; Theme-Wechsel erfolgt via `data-theme="dark|light"` auf `<html>`.

## Theme-Umschaltung

### User-Setting
- Feld: `dim_crm_users.theme_preference ENUM('dark','light','system') DEFAULT 'dark'`
- `system` = folgt OS-Präferenz via `prefers-color-scheme`.
- UI: Einstellungs-Seite `/settings/appearance` → Radio-Group (Dark / Light / System).
- Endpunkt: `PATCH /api/v1/me/preferences { theme_preference }`.
- Persistenz: DB + LocalStorage (für instant-apply beim App-Start, bevor Server-Response).
- Default für Neu-User: `dark` (bleibt ARK-Identität).

### Anwendung
```ts
// Boot-Sequenz
const pref = localStorage.getItem('theme') ?? user.theme_preference ?? 'dark';
const effective = pref === 'system'
  ? (matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark')
  : pref;
document.documentElement.setAttribute('data-theme', effective);
```

## Semantic Colors — Dark (Default)

```css
:root, [data-theme="dark"] {
  /* Background */
  --bg-primary:      #0E1116;
  --bg-secondary:    #161B22;
  --bg-tertiary:     #21262D;
  --bg-elevated:     #2D333B;

  /* Text */
  --text-primary:    #E6EDF3;
  --text-secondary:  #8B949E;
  --text-muted:      #6E7681;
  --text-disabled:   #484F58;

  /* Brand (Gold-Akzent) */
  --accent-gold:     #D4A84B;
  --accent-gold-dim: #8A6D2B;

  /* Status */
  --status-success:  #3FB950;
  --status-warning:  #D29922;
  --status-danger:   #F85149;
  --status-info:     #58A6FF;

  /* Temperatur */
  --temp-hot:        #F85149;
  --temp-warm:       #D29922;
  --temp-cold:       #58A6FF;

  /* Schutzfrist */
  --shield-active:   #3FB950;
  --shield-expired:  #6E7681;

  /* Confidence (Scraper) */
  --conf-high:       #3FB950;
  --conf-medium:     #D29922;
  --conf-low:        #F85149;

  /* Borders & Dividers */
  --border-default:  #30363D;
  --border-muted:    #21262D;
  --border-focus:    #D4A84B;

  /* Shadows */
  --shadow-drawer:   0 8px 24px rgba(0,0,0,0.4);
  --shadow-modal:    0 16px 48px rgba(0,0,0,0.6);
}
```

## Semantic Colors — Light

```css
[data-theme="light"] {
  /* Background */
  --bg-primary:      #FFFFFF;
  --bg-secondary:    #F6F8FA;
  --bg-tertiary:     #EAEEF2;
  --bg-elevated:     #FFFFFF;

  /* Text */
  --text-primary:    #1F2328;
  --text-secondary:  #59636E;
  --text-muted:      #818B98;
  --text-disabled:   #B1BAC4;

  /* Brand — gleicher Gold-Akzent (etwas dunkler für Kontrast) */
  --accent-gold:     #B8892F;
  --accent-gold-dim: #D4A84B;

  /* Status (kontrast-optimiert für helle BG) */
  --status-success:  #1A7F37;
  --status-warning:  #9A6700;
  --status-danger:   #CF222E;
  --status-info:     #0969DA;

  /* Temperatur */
  --temp-hot:        #CF222E;
  --temp-warm:       #9A6700;
  --temp-cold:       #0969DA;

  /* Schutzfrist */
  --shield-active:   #1A7F37;
  --shield-expired:  #818B98;

  /* Confidence (Scraper) */
  --conf-high:       #1A7F37;
  --conf-medium:     #9A6700;
  --conf-low:        #CF222E;

  /* Borders & Dividers */
  --border-default:  #D1D9E0;
  --border-muted:    #EAEEF2;
  --border-focus:    #B8892F;

  /* Shadows — weicher im Light Mode */
  --shadow-drawer:   0 8px 24px rgba(31,35,40,0.08);
  --shadow-modal:    0 16px 48px rgba(31,35,40,0.16);
}
```

## Regel: Komponenten nutzen nur Tokens

Komponenten referenzieren ausschliesslich `var(--token-name)`, niemals Hex-Werte direkt. Kontrast-Check WCAG AA Pflicht in beiden Themes (Tooling: axe-core in CI).

## Spacing Scale (themeunabhängig)

```css
--space-1: 4px;   --space-2: 8px;   --space-3: 12px;
--space-4: 16px;  --space-5: 24px;  --space-6: 32px;
--space-7: 48px;  --space-8: 64px;
```

## Typography

```css
--font-sans:  "Inter", system-ui, sans-serif;
--font-mono:  "JetBrains Mono", monospace;

--fs-xs: 11px;  --fs-sm: 12px;  --fs-base: 14px;
--fs-md: 16px;  --fs-lg: 18px;  --fs-xl: 24px;
```

## Component Radii

```css
--radius-sm: 4px;   --radius-md: 6px;
--radius-lg: 8px;   --radius-xl: 12px;
```

## Drawer-Breiten

| Drawer-Typ | Breite |
|------------|--------|
| Slide-in Standard (Prozess, Kandidat-Drawer) | 540px |
| Wide Drawer (Assessment-Run, Option-Config) | 720px |
| Mini Drawer (Quick-Create, Assignment) | 400px |

## Related

[[frontend-architektur]], [[frontend-freeze]]
