# Mockups Index

UI mockups for ARK CRM. Load individual files only when needed — do NOT load all at once.

## Structure

```
mockups/
  crm.html                     Main CRM shell / navigation frame
  Vollansichten/               Full detail views (single record)
  Listen/                      List/table views (multi-record)
  ERP Tools/                   Internal tools (HR, billing, commission, time, elearn)
```

## Vollansichten (Detail Views)

| File | Module | Notes |
|------|--------|-------|
| `Vollansichten/dashboard.html` | Dashboard | KPIs, activity feed |
| `Vollansichten/candidates.html` | Kandidaten | 10-tab detail mask |
| `Vollansichten/mandates.html` | Mandate | Mandate detail with stages |
| `Vollansichten/accounts.html` | Accounts | Company/client detail |
| `Vollansichten/jobs.html` | Jobs | Job detail mask |
| `Vollansichten/projects.html` | Projekte | Project detail |
| `Vollansichten/processes.html` | Prozesse | Process/pipeline detail |
| `Vollansichten/assessments.html` | Assessments | Assessment detail |
| `Vollansichten/groups.html` | Firmengruppen | Group detail |
| `Vollansichten/reminders.html` | Reminders | Reminder management |
| `Vollansichten/stammdaten.html` | Stammdaten | Master data config |
| `Vollansichten/email-kalender.html` | Email/Kalender | Email + calendar integration |
| `Vollansichten/dok-generator.html` | Dok-Generator | Document generation |
| `Vollansichten/admin.html` | Admin | System administration |
| `Vollansichten/admin-dashboard-templates.html` | Admin Templates | Dashboard template editor |
| `Vollansichten/scraper.html` | Scraper | Data scraping tool |

## Listen (List Views)

| File | Module |
|------|--------|
| `Listen/candidates-list.html` | Kandidaten list with filters |
| `Listen/mandates-list.html` | Mandate list |
| `Listen/accounts-list.html` | Accounts list |
| `Listen/jobs-list.html` | Jobs list |
| `Listen/projects-list.html` | Projekte list |
| `Listen/processes-list.html` | Prozesse list |
| `Listen/groups-list.html` | Firmengruppen list |
| `Listen/assessments-list.html` | Assessments list |

## ERP Tools

| Folder | Module | Key Files |
|--------|--------|-----------|
| `ERP Tools/billing/` | Billing | billing.html, billing-dashboard.html, billing-rechnungen.html, billing-mahnwesen.html |
| `ERP Tools/commission/` | Provisionen | commission.html, commission-dashboard.html, commission-my.html, commission-team.html |
| `ERP Tools/hr/` | HR | hr.html, hr-dashboard.html, hr-list.html, hr-mitarbeiter-self.html |
| `ERP Tools/zeit/` | Zeiterfassung | zeit.html, zeit-dashboard.html, zeit-list.html, zeit-meine-zeit.html |
| `ERP Tools/elearn/` | E-Learning | elearn.html, elearn-course.html, elearn-lesson.html, elearn-quiz.html |

## Mobile Views

- `admin-mobile.html` — Admin mobile
- `crm-mobile.html` — CRM mobile
- `dashboard-mobile.html` — Dashboard mobile

## Common Patterns

All mockups use consistent structure:
- `.tab-nav` — Tab navigation bar
- `.sidebar` — Left navigation sidebar
- `.detail-header` — Record header with actions
- `.card` — Content cards
- Dark theme: `#1a1a2e` background, `#16213e` cards, `#0f3460` accents
- Primary accent: `#e94560`

## Related Specs

- `../specs/` — Interaction + schema specs per module
- `../wiki/concepts/frontend-architektur.md` — Frontend architecture decisions
- `../wiki/concepts/design-tokens.md` — Design system tokens
