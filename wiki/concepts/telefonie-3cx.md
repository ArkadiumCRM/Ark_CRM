---
title: "Telefonie (3CX)"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md"]
tags: [concept, telefonie, 3cx, integration]
---

# Telefonie (3CX)

Dual-Integration: CRM Template (Server Side) + Webhook (Event-based).

## Funktionen

- **Click-to-Call** — Anruf direkt aus CRM starten
- **Screen-Pop** — Bei eingehenden Anrufen: Kandidaten-Karte öffnet sich
- **Auto History-Eintrag** — Anruf wird automatisch als Activity geloggt
- **Transkription** — Call wird transkribiert
- **AI-Summary** — Zusammenfassung, Action Items, Red Flags

## CRM Template (Server Side)

Auth: API Key

| Endpoint | Zweck |
|----------|-------|
| `GET /api/3cx/lookup` | Telefonnummer → Kandidat/Kontakt |
| `GET /api/3cx/lookup-email` | Email → Kandidat/Kontakt |
| `POST /api/3cx/report-call` | Call-Daten loggen |

Gibt CRM-URLs zurück (Web + Electron Deep Link: `ark-crm://candidates/[uuid]`).

## Webhook (Event-based)

Auth: HMAC Signature + optionale IP Whitelist. Replay Protection (5 Min Timestamp-Freshness).

Events: `call.received`, `call.transcript_ready`, `call.missed`

Verarbeitung: `fact_history` + Event in **einer Transaktion**. Transcript triggert AI Summary Worker.

## Phone Matching

`fact_call_context` — Telefonnummer → Entity Mapping. Ermöglicht Screen-Pop bei eingehenden Anrufen.

## SLOs

- Call → History: < 30 Sekunden
- Transcript → Summary: < 3 Minuten

## Related

- [[history-system]] — Anrufe als Activity-Types
- [[ai-system]] — Transkription und Summary
- [[email-system]] — Zweiter Kommunikationskanal
