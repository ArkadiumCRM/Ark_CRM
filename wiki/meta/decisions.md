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
