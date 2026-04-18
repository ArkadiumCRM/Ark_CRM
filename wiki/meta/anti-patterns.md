---
title: "ARK Anti-Patterns"
type: meta
created: 2026-04-17
updated: 2026-04-17
tags: [rules, anti-pattern, lint]
---

# ARK Anti-Patterns — Was NIEMALS tun

Auto-loaded via SessionStart-Hook. Referenz für jede Edit-Operation auf Mockups/Specs/Wiki.

## UI / Mockups

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **Modal für CRUD** | Drawer-Default-Regel 14.04.2026 | Drawer 540px slide-in (CLAUDE.md §Drawer-Default) |
| **Modal für Bestätigungen mit Eingabefeldern** | Mehrschritt-Eingabe = Drawer | Drawer |
| **9-Kachel-Grid für Stage-Pipeline** | Drift zu `candidates.html` Tab 6 | SVG-Linie + 9 Dots + Diamant-Placement (mockup-baseline.md) |
| **DB-Namen in UI-Text** (`dim_process_stages`, `candidate_id`, `fact_placement`) | User braucht keine Tech-Details | Sprechende Begriffe: "Prozess-Phasen", "Kandidat", "Platzierung" → kanonische Mappings siehe [[mockup-baseline]] §16 |
| **`_id`/`_fk`-Suffixe in Labels/Tooltips** | Schema-Leak | Entity-Name ohne Suffix |
| **snake_case Enum-Values** (`email_dossier`, `matching_computed`, `stage_changed`) in UI | DB-Code-Leak | Deutsche Labels aus [[mockup-baseline]] §16 ("Dossier per E-Mail", "Matching berechnet", "Stage geändert") |
| **Route-Placeholders** (`/mandates/[id]`, `/processes/[id]`) in User-sichtbarem Text | Tech-Syntax-Leak | Sprechende Bezeichnung: "Mandat-Vollansicht", "Prozess-Vollansicht" — [[mockup-baseline]] §16.10 |
| **Click-only Date-Picker** (kein Keyboard-Input) | Datum-Eingabe-Regel 14.04.2026 | Nativer `<input type="date">` / `datetime-local` / `time` |
| **Drawer-Width ≠ 540px** | Konsistenz-Drift | 540px slide-from-right, Escape + Backdrop-Click schliesst |
| **Freitext-Activity-Bezeichnungen** in Timeline | Stammdaten-Wording-Regel | Nur 64 Activity-Types aus STAMMDATEN §14 |
| **"Peter Wiederkehr" als Mitarbeiter-Label** | Darstellungs-Konvention | 2-Buchstaben-Kürzel: PW / JV / LR |
| **Stage-Rendering lokal erfinden** | Drift-Risk | Shared-Component aus `mockup-baseline.md` |
| **Neue Mockup-Seite ohne Blick auf `candidates.html`** | Reference-File ignorieren | Erst Baseline lesen, dann kopieren |

## Sprache / Umlaute

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **`ae`/`oe`/`ue`-Ersatz** (fuer, ueber, koennen, muessen) | Umlaute-Regel 15.04.2026 | `für` `über` `können` `müssen` (UTF-8) |
| **`ss` statt `ß` bei langem Vokal** (Strasse, gross, Spass) | Rechtschreibung | `Straße` `groß` `Spaß` -- ABER: Schweizer CH-Content `ss` ist OK! |
| **Surrogate-Pair-Hack** (`\ud83c\udfd7` in Python-Strings) | Encoding-Katastrophe | Echte Unicode-Zeichen direkt |

## Terminologie (ARK-spezifisch)

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **"Briefing" auf Account/Job-Seite** | Briefing = Kandidat-Eignungsgespräch | "Stellenbriefing" (Kunde ↔ über Stelle) |
| **"Arkadium führt Interview"** | Arkadium-Rolle-Regel 16.04.2026 | Interviews = Kandidat ↔ Kunde. Arkadium macht Briefing / Coaching / Debriefing / Referenzauskunft |
| **"TI" als Arkadium-Phoneinterview** | Falsche Zuordnung | TI = Telefon/Teams-Interview Kandidat ↔ Kunde |
| **Mandat-Typ "Retainer" / "Einzelmandat"** | Stammdaten-Regel | Nur: Target / Taskforce / Time |
| **Stage-Namen "Identified" / "Briefing" / "Angebot"** | Falsch | Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement |
| **EQ-Dimension "Stress-Management" / "Anpassungsfähigkeit"** | Das wäre EQ-i 2.0, nicht EQ-TriMetrix | Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung |
| **Motivatoren freitext** (Leistung, Stabilität, Autonomie) | Stammdaten §67b | Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell (je 2 Pole) |
| **Sparten "Hochbau" / "Tiefbau"** | Das sind Cluster, nicht Sparten | ARC · GT · ING · PUR · REM |
| **Schutzfrist im Post-Placement-Kontext** | Schutzfrist-Regel 16.04.2026 | Nur bei NICHT-Placement (Direkt-Einstellungs-Schutz). Post-Placement = Garantiefrist (3 Mt) |
| **"Kandidat bewirbt sich über Platform"** | Workflow-Missverständnis | ARK-Workflow ist Headhunting, kein Application-Tracking |

## Architektur / Business-Logik

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **Provisions-Engine in CRM 1.0 einbauen** | Commission-Model v1/v2 | CRM 1.0: nur Net-Fees erfassen + Zuteilungsfelder. Provisions-Engine = CRM 2.0 |
| **Direkt zu "Placement"-Stage skippen** | V1-V7 Placement-Saga | Stage-Skip nur bis Angebot OK. Placement = formaler Saga-Step mit Billing-Trigger |
| **UI-State als separaten Boolean** (z.B. `is_coaching_done`) | Activity-Linking-Regel 16.04.2026 | UI-Status berechnen aus `fact_history`-Event-Existenz. Single Source of Truth |
| **`fee_percent` auf Mandat-Prozess** | Fee-Calculation-Regel | Fee% nur für Non-Mandat-Prozesse, auto-calc auf TC Salary |
| **Early-Exit generisch behandeln** | Refund-Model-Routing | Routing auf `business_model`: Erfolgsbasis=Staffel, Mandat=Ersatz, Time=keine |
| **Jobbasket-Flow "verbessern" ohne Rückfrage** | Funktioniert wie er ist | NIE ohne User-Freigabe ändern |
| **Tag-Creation "+ Erstellen" für User** | Admin-only | Tag-Creation ausschliesslich Admin-Dialog |
| **Mock DB in Tests** | Burn-Incident | Integration-Tests mit realer DB (Supabase), nicht Mock |

## Datei-Operationen

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **`python -c "open('w')..."` auf existierende Datei** | Datei-Schutz-Regel 15.04.2026 | `Edit`/`Write`-Tool oder `out.tmp` + atomic `mv` |
| **Bash-Heredoc-Patch ohne Backup** | Truncate-Risk bei UnicodeError | Backup nach `backups/<file>.<YYYY-MM-DD-HHMM>.bak` ZUERST |
| **Edit >100 Zeilen ohne Backup** | Rollback unmöglich | Backup schreiben, dann `Edit` |
| **Amend-Commits für bereits gepushte Commits** | Historie zerstört | NEW commit stattdessen |
| **`--no-verify` bei Git-Commits** | Hooks umgehen = Fehler verstecken | Root-Cause fixen, nicht Hook skippen |

## Auto-Commit-Verhalten

| Anti-Pattern | Warum | Stattdessen |
|---|---|---|
| **Fragen "soll ich committen?"** | User-Regel | Immer auto-commit + push (feedback_auto_commit.md) |
| **Commit-Scope unklar** | Review-Risiko | Ein logischer Schritt = ein Commit, mit `Co-Authored-By: Claude...` Footer |

## Quick-Check bei jedem Edit

1. **Mockup?** → Baseline lesen, Drawer-Regel, DB-Names-Regel, Stammdaten-Regel
2. **Spec?** → Spec-Sync-Regel (5 Grundlagen + 9 Specs bidirektional)
3. **Grundlage?** → Digest wird stale → nach Commit regenerieren
4. **>5KB File?** → Backup ZUERST
5. **Umlaute echt?** → keine `ae/oe/ue` Ersätze
6. **Business-Term?** → gegen STAMMDATEN §X prüfen

## Quellen

- [CLAUDE.md](../../CLAUDE.md) — 12 CRITICAL-Rules
- [wiki/meta/digests/stammdaten-digest.md](digests/stammdaten-digest.md) — Enum-Katalog
- [wiki/meta/digests/frontend-freeze-digest.md](digests/frontend-freeze-digest.md) — Design-System
- [MEMORY.md](../../../Users/PeterWiederkehr/.claude/projects/C--ARK-CRM/memory/MEMORY.md) — Session-Memory
- [mockup-baseline.md](mockup-baseline.md) — Component-Snippets
