---
title: "MCP Setup Guide"
type: meta
created: 2026-04-18
updated: 2026-04-18
tags: [mcp, setup, tools, api-keys]
---

# MCP Setup Guide

Installations-Anleitung für die drei Cross-Provider-MCPs: **Codex** (OpenAI inkl. o3), **Perplexity** (Web-Research), **DeepSeek** (alternativ Reasoning-Tasks).

## Voraussetzungen

- Node.js ≥ 20 (check: `node --version`) ✅ du hast v24
- Claude Code CLI ≥ 2.x ✅ du hast 2.1.112
- API-Keys (siehe je Sektion)

## API-Keys besorgen

| Provider | Signup | Pricing |
|----------|--------|---------|
| **OpenAI** (Codex + o3) | https://platform.openai.com/api-keys | o3 pay-per-token, dashboard |
| **Perplexity** | https://www.perplexity.ai/settings/api | $5/mo pro Plan / pay-per-use |
| **DeepSeek** | https://platform.deepseek.com/api_keys | pay-per-token, sehr günstig |

Du hast OpenAI-Key. Perplexity + DeepSeek-Keys musst du noch anlegen.

---

## 1. Codex-MCP (OpenAI inkl. o3)

### Install

🖥️ **Terminal** (Git Bash / PowerShell im ARK-Projekt-Ordner):

```bash
setx OPENAI_API_KEY "sk-proj-DEIN-KEY"
# Danach Terminal neu öffnen damit env-var sitzt
```

Dann MCP hinzufügen:
```bash
claude mcp add codex -s user --env OPENAI_API_KEY=$OPENAI_API_KEY -- npx -y codex-mcp-server
```

`-s user` = global verfügbar (alle Projekte), nicht nur ARK.

### Verify

```bash
claude mcp list
```

Soll zeigen: `codex` mit status `✓ connected`.

### Usage in Claude Code

Nach Restart verfügbar als Tools `mcp__codex__*`. Ich call sie automatisch bei:
- Code-Reviews (Cross-Provider vor PR-Merge)
- Spezifische Refactorings wo o3-Reasoning hilft
- Write_code / explain_code / debug_code für Subtasks

---

## 2. Perplexity-MCP (Web-Research mit Citations)

### Install

🖥️ **Terminal:**

```bash
setx PERPLEXITY_API_KEY "pplx-DEIN-KEY"
```

```bash
claude mcp add perplexity -s user --env PERPLEXITY_API_KEY=$PERPLEXITY_API_KEY -- npx -y @perplexity-ai/mcp-server
```

### Verify

```bash
claude mcp list
```

Soll zeigen: `perplexity` ✓.

### Usage in Claude Code

Besser als WebSearch für:
- Recherche mit Quellen-Citations (Perplexity trackt Quellen)
- Konkurrenzanalyse, Marktdaten (Baubranche CH)
- Legal-Research (DSG-Updates, AGB-Templates)
- Aktuelle Bibliotheks-Dokumentation wenn context7 nicht reicht

Ich nutze es automatisch bei Research-Fragen mit Quellen-Anforderung.

---

## 3. DeepSeek-MCP (alternativ Reasoning)

### Install

🖥️ **Terminal:**

```bash
setx DEEPSEEK_API_KEY "sk-DEIN-KEY"
```

```bash
claude mcp add deepseek -s user --env DEEPSEEK_API_KEY=$DEEPSEEK_API_KEY -- npx -y @arikusi/deepseek-mcp-server
```

*(Falls `@arikusi/deepseek-mcp-server` nicht existiert, community package nutzen — [Liste auf mcp.so](https://mcp.so/?q=deepseek))*

### Verify

```bash
claude mcp list
```

### Usage

DeepSeek R1 für Reasoning-heavy Tasks wo o3 zu teuer ist. Overlap mit Codex-MCP, nur nutzen wenn spezifischer Bedarf.

---

## Nach Install · Test-Prompts

In neuer Claude Code Session testen:

```
# Codex Test
"Nutz Codex um diesen Code zu reviewen: [Snippet]"

# Perplexity Test
"Recherchier via Perplexity: aktuelle DSG-Anforderungen für Personal-CRMs in CH 2026"

# DeepSeek Test
"Nutz DeepSeek R1 für Reasoning: [Komplex-Problem]"
```

Wenn Claude die Tools nicht findet: Session neu starten, `claude mcp list` prüfen.

---

## Troubleshooting

**"command not found: claude"** → Pfad prüfen: `which claude` soll `/c/Users/PeterWiederkehr/.local/bin/claude` zeigen

**"env var not set"** → Neues Terminal öffnen nach `setx`. Alte Terminal-Sessions sehen setx-Changes nicht.

**"connection failed"** → `claude mcp list` zeigt Status. Bei rotem Cross → `claude mcp test <name>` für Details.

**MCP entfernen:** `claude mcp remove <name> -s user`

---

## Security Notes

- API-Keys gehen in **User-Env-Vars** (`setx ...`), nicht in Git-Repo
- MCP-Server liefen als Subprocess von Claude Code (auf deinem Rechner)
- Rate-Limits: alle 3 Provider haben Usage-Caps — Dashboard-Check monatlich empfohlen
- Bei Compromise: Key rotieren auf Provider-Dashboard, dann `setx ...` neu

---

## Wer wann

| Task | Claude | Codex/o3 | Perplexity | DeepSeek |
|------|--------|----------|------------|----------|
| Mockup/Spec-Edits | ✅ Default | — | — | — |
| Langer Code-Refactor | ✅ Primär | 🟡 Cross-Review | — | — |
| Code-Review vor PR-Merge | ✅ Primär | ✅ Zweite Meinung | — | — |
| Web-Research + Citations | 🟡 basic | — | ✅ Primär | — |
| Komplex-Reasoning (Math/Logic) | ✅ Default | 🟡 o3 wenn tiefer | — | ✅ günstiger R1 |
| Baubranche-News/Trends | — | — | ✅ Primär | — |
| Konkurrenz-Scan | — | — | ✅ Primär | — |

Faustregel: Ich nutze Claude als Default, rufe die anderen via MCP wenn spezifischer Nutzen (wird in Chat transparent angekündigt).

## Related

- [[decisions]] — Warum Cross-Provider-Setup
- [[autoresearch]] — Nutzt Perplexity für Autonomes Research-Loop
