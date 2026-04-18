---
title: "ARK Decision Log"
type: meta
created: 2026-04-17
updated: 2026-04-17
tags: [decisions, governance, adr]
---

# ARK Decision Log

Append-only Log aller projekt-prägenden Entscheidungen. Verhindert Re-Litigation (wiederholtes Diskutieren gleicher Fragen) und gibt späteren Sessions Kontext.

**Format pro Eintrag:**
```
## [YYYY-MM-DD] Kurztitel (max 8 Wörter)

- **Kontext:** Was war das Problem / die Frage?
- **Entscheidung:** Was wurde beschlossen?
- **Alternativen:** Was wurde verworfen und warum?
- **Konsequenz:** Was folgt daraus (Code, UI, Prozess)?
- **Revisit:** unter welchen Bedingungen neu verhandelbar?
```

**Wartungs-Regel für Assistant:**
Bei jeder User-Entscheidung von Tragweite (neue Regel, Architektur-Wahl, Scope-Cut, UI-Pattern-Wahl, Prozess-Änderung) → **hier eintragen**. Nicht bei Trivialitäten (Naming von einzelnen Variablen, CSS-Pixel-Werte).

---

## [2026-04-18] Harness-Evolution v2: Cross-Provider-MCPs, Routines, Autoresearch, Karpathy

- **Kontext:** Peter wollte Setup grundlegend überdenken. Skills/MCPs/Hooks/Routines/Lints waren vorhanden aber ausbaufähig. Karpathy-Principles, Claude Design, Cross-Provider-Integration (Codex/Perplexity/DeepSeek), Autoresearch, OpenClaw/Hermes standen zur Diskussion.
- **Entscheidung:** 
  1. **Karpathy-Skill** lokal unter `.claude/skills/karpathy/` (4 Principles: Think-Before-Coding, Simplicity-First, Surgical-Changes, Goal-Driven-Execution).
  2. **Claude Design** (Anthropic Labs, launched 18.04.2026) als Phase-2-Mockup-Werkzeug → Handoff-Bundle zu Claude Code. Browser-only, kein Desktop.
  3. **Cross-Provider-MCPs**: Codex (OpenAI inkl. o3), Perplexity (Web-Research+Citations), DeepSeek (günstiges Reasoning). Setup-Guide: `wiki/meta/mcp-setup-guide.md`. Peter installt manuell im Terminal nach Key-Beschaffung.
  4. **OpenClaw + Hermes verworfen** — Konkurrenz-Frameworks zu Claude Code, kein Integrations-Nutzen.
  5. **3 Cloud-Routines** (laufen unabhängig von Peter's Laptop):
     - `ark-weekly-drift` (Mo 09:00 CEST) — Drift-Scan → `drift-log.md`
     - `ark-weekly-po-agenda` (Mi 09:00 CEST) — Agenda → `po-review-agenda-YYYY-MM-DD.md`
     - `ark-daily-digest-staleness` (Di-So 08:00 CEST) — STALE.md-Flags
     Kontrolle: https://claude.ai/code/scheduled
  6. **`ark-autorefine` Skill** — Karpathy-Autoresearch-Pattern adaptiert für Phase-1-Cleanup. Human-in-Loop MVP (kein Auto-Apply ohne Peter-OK). `.claude/skills/ark-autorefine/`.
  7. **Bypass-Permissions global** in `~/.claude/settings.json` mit Hard-Deny-Guards (rm -rf, git force, DROP TABLE, etc.). Assistant self-checks kritische Ops in Chat.
  8. **Caveman-Lite** als Default in `%APPDATA%/caveman/config.json`.
  9. **2 neue Slash-Commands**: `/ark-po-review`, `/ark-phase2-plan`.
  10. **Git-Repo etabliert**: https://github.com/ArkadiumCRM/Ark_CRM (private). Audio/Video in `raw/` per .gitignore excluded (> 100MB limit).
  
- **Alternativen verworfen:**
  - LangChain / OpenClaw / Hermes als Parallel-Framework (Konkurrenten zu Claude Code).
  - Codex als Komplett-Ersatz für Claude (zweite LLM-Billing ohne klaren Mehrwert ausser Cross-Review).
  - Autoresearch vollautonom overnight (ARK braucht semantic Validator, nicht nur Lint-Count → Human-in-Loop).
  - Hermes für spezifische Subtasks (redundant, alles was Hermes kann hat Claude Code).
  - Phase-2-Code-Start jetzt (Peter will zuerst Phase-1-Cleanup + ERP-Module als Specs/Mockups).
  
- **Konsequenz:**
  - Peter bedient Setup-Alltag via 4 Oberflächen: Claude Code (default), Claude Desktop (brainstorm), Claude Design (neue Mockups), Obsidian (Wiki-Browse).
  - Cross-Provider-Nutzung wird im Chat transparent angekündigt ("Ich lass Codex das Refactor reviewen...").
  - Routines produzieren 3 Artefakte/Woche die Peter Montag/Mittwoch reviewt.
  - Autorefine-Loop kann ab sofort via "autorefine nächster Punkt" gestartet werden.
  
- **Revisit:** 
  - Permission-Bypass: nach 2-4 Wochen prüfen ob Self-Check-Regel zuverlässig greift. Bei Regelbruch → zurück zu `defaultMode: auto` mit Classifier.
  - Routines: nach 4 Runs prüfen ob Signal-zu-Noise stimmt. Sonst Anpassung der Prompts.
  - Codex/Perplexity/DeepSeek: nach 1 Monat ROI-Check (wirklich bessere Outputs vs Kosten?).
  - Autorefine v2 (Auto-Apply für SAFE-Categories): erst nach 20+ erfolgreich-iterierten Zyklen manuell.

## [2026-04-17] Grundlagen-Digests + Auto-Lint-Hooks etabliert

- **Kontext:** SessionStart-Hook sprengte Inline-Limit (200k Token) → Grundlagen nie im Context. User musste Stages/Flows/Business-Logik wiederholt erklären.
- **Entscheidung:** 5 Grundlagen-Digests (~42k Token total, Enums lossless, Prosa lossy) + 3 neue Hooks (Auto-Lint Post-Edit, Digest-Staleness-Check, Pre-Edit-Hint) + Anti-Pattern-Digest + Decision-Log + Mockup-Baseline.
- **Alternativen:** (a) Volltext chunked einmalig pro Session laden (~300k Context-Verbrauch, zu teuer wenn Arbeit folgt). (b) Nur on-demand Read (vergessens-anfällig, driftet zu manuellen Re-Erklärungen). (c) CLAUDE.md fett machen (schlecht wartbar, 200k-Inline-Problem bleibt).
- **Konsequenz:** Jede Session ~42k Digest-Context + Anti-Patterns + Decisions + Baseline auto-geladen. Präzisions-Arbeit (exakte Spalten/Endpoints) erfordert explizite User-Freigabe vor Volltext-Read.
- **Revisit:** Wenn Digests driften (Grundlagen-Edit → STALE.md Flag) → Regeneration. Wenn Auto-Lint False-Positives nervt → Patterns tunen in `.claude/hooks/ark-lint.ps1`.

## [2026-04-16] Arkadium ist NICHT Interview-Teilnehmer

- **Kontext:** Mehrfach Verwechslung "Arkadium führt Interview / macht TI". Falsches mentales Modell.
- **Entscheidung:** Interviews (TI / 1st / 2nd / 3rd / Assessment) laufen ausschliesslich zwischen Kandidat ↔ Kunde. Arkadium-Touchpoints ausschliesslich: Briefing (mit Kandidat, einmalig nach Hunt), Coaching (vor Interview), Debriefing (nach Interview, beidseitig), Referenzauskunft (vor Placement).
- **Alternativen:** Keine -- ist fachliche Realität der Headhunting-Boutique.
- **Konsequenz:** Alle UI-Texte/Labels/Tooltips/Timeline-Events müssen diese Rolle sauber abbilden. Activity-Type-Mapping in STAMMDATEN §14.
- **Revisit:** Nicht revisitbar (Business-Realität).

## [2026-04-16] Schutzfrist ≠ Garantiefrist

- **Kontext:** UI-Verwechslung: Garantiefrist (3 Mt post-Placement) vs Schutzfrist (12/16 Mt bei NICHT-Placement).
- **Entscheidung:** Getrennte UI-Flächen. Garantie: Post-Placement-Timeline / 3 Check-Ins. Schutzfrist: Separate Account-Tab / Kandidat-Tab "Offene Schutzfristen". Schutzfrist greift NUR wenn Prozess OHNE Placement endet (Rejection/Stale/Closed).
- **Alternativen:** Gemeinsames Widget "Post-Placement" -- verworfen, weil semantisch unterschiedlich.
- **Konsequenz:** Mockups candidates.html/accounts.html haben separate Tabs/Widgets.
- **Revisit:** Nicht revisitbar (AGB §6 + Vertragslogik).

## [2026-04-14] Drawer 540px als CRUD-Default

- **Kontext:** Inkonsistente Dialog-Typen (Modal, Drawer, Sheet) über Mockups.
- **Entscheidung:** CRUD + Mehrschritt-Eingaben + Bestätigungen mit Feldern → Drawer 540px slide-from-right. Modal NUR für kurze Confirms / Blocker / System-Notifications ohne Formular.
- **Alternativen:** Modal-Default (rejected, keine mobile-responsive Antwort). Bottom-Sheet (rejected, desktop-first Produkt).
- **Konsequenz:** Alle 9 Detailmasken + Drawer-Pattern aus `mockup-baseline.md`. Lint-Hook flaggt Modal+Form-Kombinationen.
- **Revisit:** Wenn neuer Entity-Typ grundsätzlich andere UX verlangt (bisher nicht eingetreten).

## [2026-04-14] Briefing vs Stellenbriefing Terminologie

- **Kontext:** Beide Begriffe im Einsatz, Semantik unscharf.
- **Entscheidung:** **Briefing** = Kandidat-Seite (Arkadium ↔ Kandidat, Eignungsgespräch nach Hunt). **Stellenbriefing** = Account/Job/Mandat-Seite (Arkadium ↔ Kunde über Stelle). Nicht vermischen.
- **Alternativen:** Einheitlicher Begriff "Briefing" (rejected, vermischt 2 Flows).
- **Konsequenz:** UI-Labels, Timeline-Events, Activity-Types entsprechend.
- **Revisit:** Nicht revisitbar.

## Tipp für Assistant

- Bei jeder User-Nachricht die eine **Regel**, **Pattern-Wahl**, oder **Scope-Cut** enthält → hier eintragen.
- Kurz halten: Kontext + Entscheidung + Konsequenz reichen meist.
- Alternativen nur ausfuehren wenn nicht-trivial verworfen (bildungsrelevant für spätere Revisits).
- NICHT eintragen: einzelne Variable-Names, CSS-Pixel, typo-fixes, one-off-Commits.
