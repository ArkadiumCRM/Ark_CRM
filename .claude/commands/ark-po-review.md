---
description: Strukturierte PO-Review-Session mit Peter — Was wurde gebaut, welche Entscheidungen offen, nächste Schritte
---

Führe einen PO-Review durch. Workflow:

## Phase 1 — Stand sammeln (automatisch)
1. Lies `wiki/meta/detailseiten-nachbearbeitung.md` — welche Punkte noch offen?
2. Lies `wiki/meta/decisions.md` — letzte 5 Entscheidungen.
3. Lies `wiki/meta/grundlagen-changelog.md` — unresolved Einträge.
4. Lies `wiki/meta/lint-violations.md` — aktuelle Violations.
5. Check `specs/` für neue/geänderte Specs (letzte 14 Tage).

## Phase 2 — Review-Agenda präsentieren
Gib Peter eine kompakte Agenda in dieser Struktur:

```
## PO-Review · [Datum]

### 1. Seit letztem Review
- [Was ist fertig]
- [Was verändert]

### 2. Offene Entscheidungen (brauchen Peter-Input)
- [Nachbearbeitungs-Punkt A mit kurzem Kontext]
- [Spec-Frage B mit Optionen]

### 3. Spec-Drift & Lint-Findings
- [Zahl + Kategorie]

### 4. Empfehlung nächste 2 Wochen
- Priorität 1: ...
- Priorität 2: ...

### Fragen an dich
1. ...
2. ...
```

## Phase 3 — Entscheidungen dokumentieren
Bei jeder Peter-Antwort die eine **Regel**, **Pattern-Wahl**, oder **Scope-Cut** ist → Eintrag in `wiki/meta/decisions.md` anhängen im Standard-Format.

## Regeln
- Keep Agenda knapp. Max 2 Sätze pro Punkt.
- Wo möglich direkte File-Links `[[page]]` oder `file:line`.
- Bei kritischen Themen: Anti-Pattern-Digest + Decision-Log referenzieren.
- Nicht mehr als 5 offene Fragen auf einmal — batch sonst.
