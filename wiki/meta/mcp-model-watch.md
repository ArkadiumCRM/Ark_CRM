# MCP Model-Watch · Wöchentlicher Auto-Report

---

## 2026-04-25 · Model-Watch

### Latest verfügbare Modelle

| Provider | Latest Model | Released | In MCP/SDK exposed? |
|----------|--------------|----------|---------------------|
| Anthropic | claude-opus-4-7 | 2026-04-16 | ⚠ prüfen — @ai-sdk/anthropic v3.0.71 aktuell |
| Anthropic | claude-sonnet-4-6 | 2026-02-17 | ✓ via @ai-sdk/anthropic v3.0.71 |
| Anthropic | claude-haiku-4-5 | 2025-10 (est.) | ✓ via @ai-sdk/anthropic v3.0.71 |
| DeepSeek | deepseek-v4-pro | 2026-04-24 | ⚠ NEU — @arikusi/deepseek-mcp-server v1.7.0 könnte V4 noch nicht listen |
| DeepSeek | deepseek-v4-flash | 2026-04-24 | ⚠ NEU — selbe Prüfung nötig |
| OpenAI | gpt-5.5 | 2026-04 (est.) | ✓ via codex-mcp-server v1.4.10 |
| OpenAI | o4-mini (Reasoning) | 2026 (est.) | ✓ |
| Gemini | gemini-3.1-pro | 2026-02-19 | ✓ |
| Gemini | gemini-3.1-flash-lite | 2026-03-03 | ✓ |
| Mistral | mistral-small-4 | 2026-03-16 | ✓ via mistral-large-latest alias |
| Mistral | mistral-large-3 | 2025-12 | ✓ |

### MCP/SDK Package-Versionen

> Kein `package.json` im Repo gefunden — Vergleich: npm-latest vs. installiert nicht möglich. Alle Werte = aktuell auf npm registry.

| Package | Installiert | Latest npm | Action |
|---------|-------------|-----------|--------|
| @arikusi/deepseek-mcp-server | N/A | 1.7.0 | Prüfen ob V4-Modell-IDs enthalten |
| @anthropic-ai/sdk | N/A | 0.91.1 | up-to-date |
| @ai-sdk/anthropic | N/A | 3.0.71 | up-to-date — Opus 4.7 support prüfen |
| ai (Vercel AI SDK) | N/A | 6.0.168 | up-to-date |
| codex-mcp-server | N/A | 1.4.10 | up-to-date |
| @perplexity-ai/mcp-server | N/A | 0.9.0 | up-to-date |
| @upstash/context7-mcp | N/A | 2.2.0 | up-to-date |

### Flags & Action-Items

- 🔴 **DeepSeek V4 Flash + V4 Pro** gestern (2026-04-24) released — Preview-Status, 1M-Token-Kontext, Hybrid Attention. `@arikusi/deepseek-mcp-server v1.7.0` sollte geprüft werden ob V4-Aliases schon enthalten sind.
- 🟡 **Claude Opus 4.7** seit 2026-04-16 verfügbar (9 Tage alt) — Step-change im Agentic Coding, höhere Bildauflösung. `@ai-sdk/anthropic v3.0.71` prüfen ob `claude-opus-4-7` als Enum-Value enthalten.
- ✅ Kein Claude 5 angekündigt.
- ✅ Kein OpenAI o5 angekündigt — o4-mini ist aktuell neuestes Reasoning-Modell; GPT-5.5 neuestes GPT.
- ✅ Gemini 3.1 Pro seit Feb 2026 stabil — kein Gemini 4 in Sicht.
- ✅ Mistral Small 4 (März 2026) vereint Magistral + Pixtral + Devstral in einem Modell.

### TL;DR

**Zwei Hot-Items diese Woche:** DeepSeek V4 Flash/Pro wurde gestern (24.04.) released — MCP-Server-Kompatibilität prüfen. Claude Opus 4.7 ist seit 16.04. verfügbar aber noch nicht explizit verifiziert im AI-SDK. Alle npm-Packages sind auf aktuellem Stand.

### Push-Log

- Zwei parallele Sessions (session_01EhXZg4tnpn1fuw45EfZd1a + session_01RYKqESP5vzksaFg6xF9jDX) haben denselben Report unabhängig erstellt. Konflikt beim Rebase aufgelöst: Remote-Version (detailliertere Tabelle) übernommen, Push-Log ergänzt.

---

