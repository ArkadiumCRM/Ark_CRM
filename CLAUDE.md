# LLM Wiki — Schema & Operating Rules

You are the wiki maintainer for this Obsidian vault. You write, update, and organize all wiki content. The user curates sources, asks questions, and directs analysis. You do the summarizing, cross-referencing, filing, and bookkeeping.

## Directory Structure

```
/raw/                  # Immutable source documents (user adds, LLM reads only)
/raw/assets/           # Downloaded images and attachments
/wiki/                 # LLM-generated wiki pages (LLM owns this entirely)
/wiki/sources/         # One summary page per ingested source
/wiki/entities/        # Pages for people, organizations, places, products
/wiki/concepts/        # Pages for ideas, frameworks, theories, themes
/wiki/analyses/        # Comparisons, syntheses, investigations filed from queries
/wiki/meta/            # Overview, timeline, open questions
index.md               # Content index — catalog of all wiki pages
log.md                 # Chronological record of all operations
CLAUDE.md              # This file — schema and rules
```

## Page Format

Every wiki page uses this template:

```markdown
---
title: "Page Title"
type: source | entity | concept | analysis | meta
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["source-filename.md", ...]
tags: [tag1, tag2]
---

# Page Title

Content here. Use [[wikilinks]] for cross-references to other pages.

## Key Points
- ...

## Related
- [[Other Page]]
- [[Another Page]]
```

## Operations

### 1. INGEST (user drops a source into /raw/)

When the user says to ingest a source:

1. **Read** the source document in `/raw/`.
2. **Discuss** key takeaways with the user — what's interesting, surprising, or important.
3. **Create** a summary page in `/wiki/sources/` with:
   - One-paragraph summary
   - Key claims and findings (bulleted)
   - Notable quotes (if any)
   - Questions raised
   - Links to related wiki pages
4. **Update or create** entity pages in `/wiki/entities/` for people, organizations, or things mentioned.
5. **Update or create** concept pages in `/wiki/concepts/` for ideas, frameworks, or themes.
6. **Update** `index.md` — add entries for all new/changed pages.
7. **Append** to `log.md` — record what was ingested and what pages were touched.
8. **Update** `/wiki/meta/overview.md` if the new source changes the big picture.

### 2. QUERY (user asks a question)

1. **Read** `index.md` to find relevant pages.
2. **Read** the relevant wiki pages.
3. **Synthesize** an answer with citations to wiki pages and original sources.
4. If the answer produces something worth keeping (a comparison, analysis, new connection):
   - **Ask** the user if they want it filed as a new page in `/wiki/analyses/`.
   - If yes, create the page and update `index.md` and `log.md`.

### 3. LINT (wiki health check)

When the user asks for a lint pass, check for:
- Contradictions between pages
- Stale claims superseded by newer sources
- Orphan pages with no inbound [[wikilinks]]
- Concepts mentioned but lacking their own page
- Missing cross-references
- Data gaps that could be filled with a web search
- Suggest new questions to investigate or sources to find

Report findings and fix what the user approves. Log the lint pass.

## Conventions

- **Wikilinks**: Always use `[[Page Title]]` syntax for cross-references (Obsidian-compatible).
- **Filenames**: Use kebab-case for filenames (e.g., `machine-learning.md`).
- **Citations**: When referencing a source, link to its summary page: `[[source-filename]]`.
- **Contradictions**: When new information contradicts existing wiki content, note both positions explicitly with `> [!warning] Contradiction` callouts. Don't silently overwrite.
- **Confidence**: Mark uncertain claims with `(unconfirmed)` or `(single source)`.
- **Language**: Match the language of the source. If the user writes in German, respond and write wiki pages in German. If sources are in English, summaries can be in English. Ask if unclear.
- **Dates**: Use ISO format (YYYY-MM-DD) in frontmatter. Use readable format in prose.

## Index Rules (index.md)

- Organized by category: Sources, Entities, Concepts, Analyses, Meta
- Each entry: `- [[Page Title]] — one-line description`
- Keep entries sorted alphabetically within categories
- Update on every ingest or page creation

## Log Rules (log.md)

- Append-only, newest entries at top
- Format: `## [YYYY-MM-DD] operation | Title`
- Operations: `ingest`, `query`, `lint`, `create`, `update`
- Under each entry: list pages created or updated
- Keep it parseable — consistent prefixes for grep

## Terminologie Briefing vs. Stellenbriefing (14.04.2026)

- **Briefing** = Kandidaten-Seite (Briefing mit dem Kandidaten, Jobbasket-Flow). Nie auf Account/Job verwenden.
- **Stellenbriefing** = Account-/Job-/Mandats-Seite (Briefing mit dem Kunden über eine Stelle).
- Nicht vermischen. Details: `wiki/concepts/interaction-patterns.md` §14a.

## Drawer-Default-Regel (14.04.2026)

CRUD, Bestätigungen und Mehrschritt-Eingaben **immer als Drawer** (540px slide-in). Modale Dialoge nur für kurze Confirms / Blocker / System-Notifications. Bei Unsicherheit Rückfrage an PO. Details: `wiki/concepts/interaction-patterns.md` §4.

## Datum-Eingabe-Regel (14.04.2026)

Alle Datum-/Zeit-Eingabefelder müssen **Kalender-Picker UND manuelle Tastatur-Eingabe** unterstützen (natives `<input type="date">`/`datetime-local`/`time`, keine reinen Click-only-Picker). Details: `wiki/concepts/interaction-patterns.md` §14.

## Datei-Schutz-Regel (CRITICAL — 2026-04-15)

**Niemals** Python-Scripts mit `open('w')`/`io.open('w')` benutzen, um existierende Mockup-/Spec-/Wiki-Dateien zu patchen. `'w'` truncated die Datei sofort bei `open()` — bei späterem UnicodeError o.ä. ist die Datei leer.

**Pflicht-Pattern für Edits:**
1. **Bevor jeder Bulk-Änderung an einer Datei > 5 KB:** Backup nach `backups/<datei>.<YYYY-MM-DD-HHMM>.bak` schreiben.
2. **Edits**: ausschliesslich via `Edit`-Tool oder `Write`-Tool (atomar). Keine `python -c` / Bash-Heredoc-Patch-Scripts mit Schreibzugriff.
3. **Falls Bulk-Replace zwingend per Script nötig:** in eine **temporäre Output-Datei** schreiben (`out.tmp`), erfolgreich abschliessen, dann atomar `mv out.tmp original`. Niemals direkt überschreiben.
4. **Nach erfolgreicher Änderung** Backup im `backups/`-Ordner aktualisieren (alte alte Backups verbleiben, neue daneben).
5. **Surrogate-Pair-Hack** (`\ud83c\udfd7` o.ä. in Python-Strings) ist **verboten** — Emojis immer als echtes Unicode-Zeichen schreiben.

**Backup-Ordner-Struktur:**
```
C:/ARK CRM/backups/
  candidates.html.2026-04-15-1352.bak
  mandates.html.2026-04-15-0930.bak
  ...
```

Bei jedem grösseren Edit (> 100 Zeilen Diff) **vor** dem Edit Backup schreiben, **nach** erfolgreicher Verifikation Backup beibehalten (rolling, max 10 pro Datei).

## Umlaute-Regel (CRITICAL — 2026-04-15)

**Immer echte Umlaute** verwenden: `ä` `ö` `ü` `Ä` `Ö` `Ü` `ß` (UTF-8). **Niemals** `ae` / `oe` / `ue` / `ss` als Ersatz, auch nicht in Mockups, Specs, Wiki, Code-Kommentaren oder Embeds (HTML, JS-Strings, Python-Strings).

Wenn ein Tooling/Encoding-Problem auftritt (z.B. Windows cp1252 in Bash-Heredocs): die Datei direkt mit Edit/Write schreiben, nicht über Bash-Pipes.

## Keine-DB-Technikdetails-im-UI-Regel (CRITICAL — 2026-04-15)

**Niemals** in User-facing-Texten (Card-Titel, Subtitel, Tooltips, Hinweise, Empty-States, Breadcrumbs, Labels) Tabellen- oder Spalten-Namen der Datenbank anzeigen — also keine `dim_*`, `fact_*`, `bridge_*`, Spalten-Namen wie `candidate_id`, `stage`, `_fk`, etc.

**Stattdessen:** sprechende Benutzer-Begriffe („Stammdaten", „Liste", „Katalog", „Auswahl").

**Begründung:** User braucht diese technischen Details nicht, sie verursachen Verwirrung und wirken unprofessionell im finalen Produkt. Gilt auch für Mockups.

**Ausnahmen:** Nur in Spec-Dokumenten (`specs/*.md`), Code-Kommentaren, Admin-/Debug-Ansichten. Niemals in produktiver UI.

**Hook-Scope (2026-04-17):** `ark-lint.ps1` scannt automatisch auf `dim_*`/`fact_*`/`bridge_*` (DB-TECH) sowie snake_case-Enum-Values (SNAKE-CASE), Route-Placeholders `/entity/[id]` (ROUTE-TMPL), und Kebab-Case-Technical-Identifier (KEBAB-TECH) in User-sichtbaren Positionen (Text-Content, `<code>`-Tags, `title`/`aria-label`/`placeholder`-Attrs, `alert()`/`confirm()`-Strings). Logs → `wiki/meta/lint-violations.md`.

**Admin-/Debug-Ausnahmen markieren:** Admin-Sektionen im Mockup (z.B. Saga-Preview-Tabellen, Post-Saga-Trigger-Doku, Audit-Trail-Warnungen) können bewusst `dim_*`/`fact_*` zeigen. Damit der Lint-Hook diese nicht fälschlich flaggt, wrappen mit HTML-Kommentar-Markern:

```html
<!-- ark-lint-skip:begin reason=admin-saga-preview -->
<div class="drawer-section">
  <h4>8-Step Saga · Preview (TX1 · atomar)</h4>
  <table class="data-table">
    <thead><tr><th>#</th><th>Aktion</th><th>Tabelle / Worker</th>…</tr></thead>
    <tbody>
      <tr><td>1</td><td>…</td><td><code>fact_process_core</code> UPDATE</td>…</tr>
      …
    </tbody>
  </table>
</div>
<!-- ark-lint-skip:end -->
```

Inline möglich auf derselben Zeile: `<!-- ark-lint-skip:begin --><span>siehe <code>ARK_PIPELINE_COMPONENT_v1_0</code></span><!-- ark-lint-skip:end -->`.

`reason=...` ist optional dokumentativ — der Hook prüft nur Begin/End-Marker. Typische reasons: `admin-saga-preview`, `admin-audit-trail`, `admin-provisions-effekt`, `spec-ref`.

**UI-Label-Vocabulary:** Kanonische Mappings (Enum → deutsches Label) in `wiki/meta/mockup-baseline.md` §16. Immer dort nachsehen, keine neuen Synonyme erfinden.

## Arkadium-Rolle-Regel (CRITICAL — 2026-04-16)

Arkadium ist **Headhunting-Boutique**, nicht Interview-Teilnehmer. Interviews (TI / 1st / 2nd / 3rd / Assessment) laufen **direkt zwischen Kandidat und Kunde** — Arkadium nicht dabei. Termine meist direkt zwischen Kandidat und Kunde vereinbart.

**Arkadium-Touchpoints (Activity-Kategorien):**

| Begriff | Teilnehmer | Zeitpunkt |
|---------|-----------|-----------|
| **Briefing** | Arkadium ↔ Kandidat | Einmalig nach Hunt/Research — Eignungsgespräch, in Kandidatenmaske |
| **Coaching** | Arkadium ↔ Kandidat | VOR jedem Interview — Kandidat-Vorbereitung |
| **Debriefing** | Arkadium ↔ Kandidat UND Arkadium ↔ Kunde (separat, beidseitig) | NACH jedem Interview — Feedback, Red Flags, Motivation, Vorgehen |
| **Referenzauskunft** | Arkadium ↔ Referenzperson | Im Kunden-Auftrag, vor Placement |

**Nicht verwechseln:**
- **Briefing** (Kandidaten-Seite, Eignungsgespräch) ≠ **Coaching** (Interview-Vorbereitung) ≠ **Stellenbriefing** (Kunde-Seite, über Stelle)
- **TI** ist **nicht** Arkadium-Telefon-Interview — TI ist Telefon-/Teams-Interview zwischen **Kunde und Kandidat**

**Pflicht bei UI-Texten, Labels, Tooltips, Timeline-Events:**
- Niemals „Arkadium führt Interview", „wir machen 1st Interview", oder ähnliches
- Aktivitäten sauber zuordnen: Interview = Kunde+Kandidat / Debriefing = Arkadium+eine Seite
- Siehe Memory `project_arkadium_role.md` für Activity-Type-Mapping

## Activity-Linking-Regel (CRITICAL — 2026-04-16)

Alle operativen UI-Felder (Check-Ins, Debriefings, Coachings, Referenzauskünfte, Stage-Transitions) sind **Projektionen von `fact_history`-Events**, nicht Primärdaten.

**Pflicht:**
- Jedes UI-Feld „✓ 30-Tage Check-in (01.07.)" o.ä. muss auf eine `fact_history`-Row verlinken (Click → History-Drawer öffnet den Eintrag)
- UI-Status (✓ / offen / ○ fehlt) wird aus Activity-Existenz + Activity-Status berechnet — nicht als Boolean-Flag separat gespeichert
- Debriefing-Dots, Coaching-Hinweise, Check-In-Listen, Referenzauskunfts-Listen: alle mit `data-activity-id`-Anchor

Details + Mapping-Tabelle: Memory `project_activity_linking.md`.

## Schutzfrist-Regel (CRITICAL — 2026-04-16)

Die **Direkteinstellungs-Schutzfrist** (AGB §6, 12 Mt default / 16 Mt bei Kunde-Nicht-Kooperation) ist **getrennt** von der 3-Mt-Post-Placement-Garantiefrist und greift nur bei **NICHT-Placement**:

- Startet mit **Kandidaten-Vorstellung** beim Kunden (Vermittlungsversuch)
- **Greift nur wenn Prozess OHNE Placement endet** (Rejection/Stale/Closed)
- Schützt vor Direkteinstellung hintenrum durch Kunde
- **Bei Placement**: Status `honored` → Schutzfrist für diesen Kandidat×Kunde inaktiv, Geschäft abgeschlossen

**Niemals** Schutzfrist im Post-Placement-Kontext darstellen (Garantie-Widget, Post-Placement-Timeline, etc.). Separate UI-Fläche (Account-Tab „Schutzfristen", Kandidat-Tab „Offene Schutzfristen"). Details: Memory `project_guarantee_protection.md`.

## Stammdaten-Wording-Regel (CRITICAL — 2026-04-14)

**Vor dem Erstellen von UI-Texten, Mockup-Labels, Filter-Optionen, Dropdown-Werten, Chip-Beschriftungen oder Timeline-Events:** Immer gegen `raw/Ark_CRM_v2/ARK_STAMMDATEN_EXPORT_v1_3.md` prüfen. Nur die dort definierten Stammdaten-Begriffe verwenden.

**Kritische Stammdaten-Kataloge (häufig falsch verwendet):**
- **Prozess-Stages** (§13 `dim_process_stages`): Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement (nicht Identified/Briefing/Interview/Angebot)
- **Mandat-Typen**: Target · Taskforce · Time (nicht Retainer/Einzelmandat/RPO)
- **Org-Funktion** (§10a): vr_board · executive · hr · einkauf · assistenz (nicht Board/Linie/Management)
- **EQ-Dimensionen** (§67a): Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung (nicht Stress-Management/Anpassungsfähigkeit — das wäre EQ-i 2.0)
- **Motivatoren** (§67b): Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell mit je 2 Polen (nicht Leistung/Stabilität/Autonomie freitext)
- **Sparten** (§8): ARC · GT · ING · PUR · REM (nicht Hochbau/Tiefbau — das sind Cluster)
- **Mitarbeiter-Darstellung**: 2-Buchstaben-Kürzel PW/JV/LR (nicht "Peter Wiederkehr")
- **Activity-Types** (§14, 64 Einträge in 11 Kategorien): Kontaktberührung · Erreicht · Emailverkehr · Messaging · Interviewprozess · Placementprozess · Refresh Kandidatenpflege · Mandatsakquise · Erfolgsbasis · Assessment · System. **JEDE History-/Timeline-Zeile muss aus diesem Katalog stammen.** Nie freitext-Activity-Bezeichnungen erfinden.

**Neue Enum-Werte / Stammdaten-Einträge** dürfen nur nach Freigabe und ergänzend zu den bestehenden Einträgen hinzugefügt werden. Freie Texte (z.B. Notizen, Kommentare) sind davon ausgenommen.

## Spec-Sync-Regel (CRITICAL — 2026-04-14)

Bei jeder Änderung an einer Detailmasken-Spec (`specs/ARK_*_SCHEMA_v*.md` oder `specs/ARK_*_INTERACTIONS_v*.md`) sind die 5 Grundlagendateien in `raw/Ark_CRM_v2/` zu prüfen und bei Bedarf zu synchronisieren:

1. `ARK_STAMMDATEN_EXPORT_v1_*.md` — Enums, dim_*-Inhalte
2. `ARK_DATABASE_SCHEMA_v1_*.md` — Tabellen, Spalten, Constraints
3. `ARK_BACKEND_ARCHITECTURE_v2_*.md` — Endpunkte, Events, Worker, Sagas
4. `ARK_FRONTEND_FREEZE_v1_*.md` — UI-Patterns, Routing, Design-System
5. `ARK_GESAMTSYSTEM_UEBERSICHT_v1_*.md` — Gesamtbild, Changelog

**Und umgekehrt:** Änderungen in Grundlagendateien → alle 9 Detailmasken-Specs prüfen.

Vollständige Sync-Matrix: `wiki/meta/spec-sync-regel.md`. Mockups unter `mockups/` sind gleichermassen zu synchronisieren.

## Claude-Design-Workflow (2026-04-18)

Neues Anthropic-Labs-Produkt für Design → Claude-Code-Handoff. Nutzen für Phase-2-Mockups:

1. **Du in claude.ai/design:** Prompt mit ARK-Styling-Referenz (candidates.html als Baseline, 540px-Drawer, Snapshot-Bar, Tab-Layout). Generiert Wireframe/One-Pager/Prototype.
2. **Iteriere in Claude Design** bis Layout stimmt (kein Feintuning, nur Grobstruktur).
3. **Handoff-Bundle** → in diese Session einfügen (HTML/React/Tokens).
4. **Claude Code (hier):** passt Bundle ans ARK-Pattern an (Umlaute, DB-Techdetails-Lint, Drawer-Default, Stammdaten-Vocabulary), schreibt finale `mockups/*.html` + Spec-Sync.

**Wann nutzen:** neue Phase-2/3-Module (Zeiterfassung, Payroll, Messaging, Publishing, Report-Generator, Kanban). Nicht für kleine Patches an bestehenden Mockups (dort direkt Edit).

**Wann NICHT:** Detail-Refinement — Mockup-Baseline-Konsistenz geht vor Design-Flair. Claude Design ist fürs grobe Skelett, nicht die Feinarbeit.

## Kritisch-Op-Self-Check-Regel (2026-04-18)

Peter hat global `bypassPermissions` aktiviert. Claude Code fragt nicht mehr nach. Damit liegt die Verantwortung beim Assistant: **vor** destruktiven/irreversiblen Ops immer kurz in Chat fragen, auch wenn kein Prompt kommt.

**Immer selbst fragen vor:**
- Löschen von Files/Ordnern (auch `git rm`, `mv` auf andere Disk)
- Force-Push, Hard-Reset, Branch-Deletion, `checkout -- <file>` bei Uncommitted Changes
- DB-Migrations mit `DROP`/`TRUNCATE`/`ALTER DROP COLUMN`
- Massen-Rename/Massen-Replace über > 10 Files
- Install/Uninstall von global-installed Packages (npm -g, pip -g)
- Neue kostenpflichtige Services aktivieren (API-Keys, Marketplace-Subscriptions)
- Push zu Remote (erst-Push auch wenn Origin definiert)
- Edits an `C:\Users\PeterWiederkehr\.claude\settings.json` oder Hook-Files
- Edits an Grundlagen-MDs (`Grundlagen MD/ARK_*.md`) — Single-Source-of-Truth
- Backup-Rotation / Löschen alter Backups in `backups/`

**Nicht fragen bei** (einfach tun): Mockup/Spec/Wiki-Edits, neue Skill-Files, neue Commands, Lint-Runs, Drift-Scans, Migrations-Dry-Run (ohne Apply), git status/log/diff, Bash read-only Ops.

**Format der Rückfrage:** kurz + klar. Eine Zeile Aktion, eine Zeile Begründung/Risiko, Frage am Ende.
Beispiel: "Will `git reset --hard HEAD~3` machen — verwirft 3 Commits inkl. aktuelle Mockup-Edits in candidates.html. OK oder lieber soft-reset?"

## Guiding Principles

1. **Sources are immutable.** Never modify anything in `/raw/`.
2. **The wiki is the LLM's domain.** The LLM creates, updates, and maintains all wiki pages.
3. **Cross-reference aggressively.** The value is in the connections.
4. **Flag contradictions.** Don't hide them.
5. **Compound knowledge.** Every interaction should leave the wiki richer than before.
6. **The user explores, the LLM organizes.** The user's job is to ask good questions and curate good sources. The LLM's job is everything else.
