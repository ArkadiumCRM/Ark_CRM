---
title: "Kontakt = Kandidat Regel"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [concept, architecture, kontakt, kandidat, design-decision]
---

# Kontakt = Kandidat Regel

> [!warning] Architektur-Entscheidung
> Jeder Kontakt bei einem [[account]] MUSS gleichzeitig ein [[kandidat]] sein.

## Regel

- `candidate_id` auf `dim_account_contacts` ist effektiv NOT NULL
- **Personen-Felder leben NUR auf `dim_candidates_profile`**
- Die Kontakt-Tabelle enthält nur account-spezifische Felder:
  - `decision_level`
  - `is_decision_maker`
  - `is_champion`
  - `is_blocker`
  - `relationship_score`

## Auswirkungen

### Bei Kontakt-Erstellung

1. Suche nach existierendem Kandidaten (Name, Email, Telefon)
2. Match gefunden → Verknüpfung
3. Kein Match → **Hard Stop**: Zuerst Kandidat erstellen, dann als Kontakt verknüpfen

### Schema-Delta

Alle Personen-Felder (Vorname, Nachname, Email, Telefon etc.) wurden von `dim_account_contacts` **entfernt**. Diese Daten kommen ausschliesslich aus der verknüpften `dim_candidates_profile`.

### Vorteile

- Single Source of Truth für Personendaten
- Automatische Duplikat-Vermeidung
- Kontakt-Personen sind sofort als Kandidaten verfügbar
- Werdegang, Assessment etc. stehen direkt zur Verfügung

### Konsequenzen

- Jede neue Kontaktperson erzeugt einen Kandidaten-Datensatz
- Potenzielle Inflation von Kandidaten-Daten
- Saubere Trennung: "Wer ist die Person?" (Kandidat) vs. "Was ist ihre Rolle bei diesem Account?" (Kontakt)

## Related

- [[kandidat]] — Kandidat-Entity (Personen-Daten leben hier)
- [[account]] — Account mit Kontakt-Tab (account-spezifische Felder leben hier)
