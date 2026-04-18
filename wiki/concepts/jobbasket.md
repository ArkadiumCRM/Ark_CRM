---
title: "Jobbasket & GO-Flow"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [concept, jobbasket, go-flow, pipeline]
---

# Jobbasket & GO-Flow

Der Weg vom Prelead bis zum CV-Versand. Tabelle: `fact_jobbasket`.

## Pipeline

```
Prelead → Oral GO → Written GO → Assigned → To Send → CV Sent / Exposé Sent
```

## Preleads

Unternehmen/Jobs die der CM dem [[kandidat|Kandidaten]] im GO-Termin vorstellen möchte.

### Flow

1. Nach GO-Termin: CM wählt passende Accounts/Jobs → kommen als Preleads in Jobbasket
2. CM bespricht Preleads mit Kandidat
3. CM versendet Email "Mündliche GOs" mit Prelead-Liste
4. Kandidat bestätigt schriftlich welche er verfolgen möchte
5. Abgelehnte Preleads erhalten differenzierten Rejection-Grund

### Rejection-Typen

| Typ | Tabelle | Bedeutung |
|-----|---------|-----------|
| Rejected Candidate | `dim_jobbasket_rejection_types` | Kandidat will nicht |
| Rejected CM | `dim_jobbasket_rejection_types` | CM findet sinnlos |
| Rejected AM | `dim_jobbasket_rejection_types` | AM findet nicht passend |

## Gate 1 (→ Assigned)

Automatisch wenn alle vorhanden:
- ✅ Schriftlicher GO
- ✅ CV hochgeladen
- ✅ Diplom hochgeladen
- ✅ Zeugnis hochgeladen

## Gate 2 (→ Versand)

Buttons erscheinen wenn:
- ✅ ARK CV oder Exposé vorhanden
- ⚠️ AGB-Check bei Erfolgsbasis (Warnung, kein Block)

**Versand erstellt automatisch einen [[prozess]].**

## Versand-Flow CV vs. Exposé (15.04.2026)

Zwei Varianten, je nach Kundenbeziehung:

**Variante A — Neuer Kunde (Exposé zuerst)**
1. ARK-CV + **Exposé (anonymisiert)** vorbereiten
2. Exposé versenden (Name/Kontakt geschwärzt) → Stage `Sent`, Fork-Node Exposé ✓
3. Kunde prüft, zeigt Interesse → CV nachliefern (Fork-Node CV ✓)
4. Schutz gegen Direkt-Kontaktierung: Kunde hat keinen Kontakt zum Kandidaten ohne ARK

**Variante B — Bekannter Kunde (direkt CV)**
1. ARK-CV + Abstract vorbereiten (kein Exposé nötig)
2. CV direkt versenden → Stage `Sent`, Fork-Node CV ✓
3. Nach CV-Versand ist **kein Exposé mehr nötig** (wäre redundant)

Beide Varianten enden in Stage `Sent`. Die Wahl trifft der AM anhand der Kundenbeziehung.

## Zentrale To-Send-Inbox (Dashboard)

**Kein Versand aus Kandidaten-Maske.** Die Versand-Buttons existieren nicht im Jobbasket-Tab. Stattdessen:

- Dashboard enthält eine **To-Send-Inbox** (alle Kandidat-Job-Kombinationen in Stage „To Send" über alle Kandidaten)
- AM öffnet die Inbox, wählt (bulk) aus und versendet zentral CV oder Exposé
- Vorteil: AM hat kompletten Überblick, kann gruppiert senden, einheitliche Qualitätssicherung

Im Jobbasket der Kandidaten-Maske wird nur der **Status** gezeigt („Auto-Weiterstellung auf To Send sobald Dok bereit").

## Live-Stage-Transitions (keine manuellen Buttons, kein Sync-Lauf)

Stages werden **live event-driven** weitergeschaltet, sobald Bedingungen erfüllt sind (sofort, kein Batch/Sync-Job):

| Trigger | Transition |
|---------|-----------|
| Email „Mündliche GOs" versendet + Empfang bestätigt | Prelead → Oral GO |
| Schriftliches GO des Kandidaten eingetroffen | Oral GO → Written GO |
| Gate 1 (4 Docs) komplett | Written GO → Assigned |
| Gate 2 (CV+Abstract für Var. B / Exposé für Var. A) komplett | Assigned → To Send |
| CV/Exposé via Dashboard-Inbox versendet | To Send → Sent |

**Keine „Auf Assigned setzen"-Buttons.** Card-Body zeigt „Live-Weiterstellung auf X sobald …" als Info-Hinweis. Jedes Event (Doc-Upload, Email-Empfang, Versand-Trigger im Dashboard) löst die Transition **sofort** aus, UI refreshed via Subscription/SSE.

## Oral GO = Warten auf schriftliches GO

Stage `Oral GO` bedeutet: mündliches GO wurde bereits im GO-Termin besprochen, das System wartet auf die **schriftliche Bestätigung** (Email/Chat). Ghosting-Hinweis nach 7 Tagen ohne schriftliche Antwort, Deadline-Tracking.

## Rejected ↔ History-Kopplung

Stage-Rejection wird **ausschliesslich über History-Einträge** erzeugt:

1. User erstellt History-Eintrag (z.B. „Absage nach GO-Termin")
2. Verknüpft Prozess/Job
3. Wählt Grund aus **stage-spezifischem Katalog**
4. System setzt Job automatisch auf `stage=-1`, speichert `rejAt=<aktuelle Stage>`, verlinkt History-ID

Das ✕-Icon in der Card öffnet einen Quick-History-Drawer (ein Shortcut, kein paralleler Flow).

## Absagegrund-Katalog · stage-sensitiv

Bestimmte Gründe sind erst ab bestimmten Stages möglich:

| Stage | Verfügbare Gründe |
|-------|-------------------|
| Prelead | Kandidat nicht erreichbar · Kandidat abgelehnt (Distanz/Branche) · ARK-intern (Dupl./Priorität) |
| Oral GO | Kandidat nach Termin abgesagt · Kulturfit · TC-Mismatch · ARK-intern |
| Written GO | Kandidat zieht zurück · TC-Erwartung nicht erfüllbar · ARK-intern (bessere Alternative) |
| Assigned | alle vorigen + Gate-1-Doc dauerhaft fehlend |
| To Send / Sent | alle vorigen + **Account lehnt ab** (erst ab hier, weil Unterlagen beim Account) · Kunde hat bereits entschieden |

Vorher unmögliche Gründe (z.B. „Account lehnt ab" bei Written GO — Account hat Profil noch nicht gesehen) sind nicht im Katalog.

## Automationen

- Email "Mündliche GOs" → Jobbasket: oral_go + Mandate Research: go_muendlich
- Schriftlicher GO eingeht → Jobbasket: written_go + Mandate Research: go_schriftlich
- Gate 1 komplett (4 Docs) → written_go → assigned
- Gate 2 komplett (CV+Abstract / Exposé) → assigned → to_send
- Versand aus Dashboard-Inbox → to_send → sent + Prozess-Erstellung + Fork-Node-Update

## Related

- [[kandidat]] — Tab 5: Jobbasket
- [[job]] — Jobs im Basket
- [[prozess]] — Entsteht aus dem Versand
- [[rekrutierungsprozess]] — Einordnung im Gesamtflow
- [[mandat]] — Synchronisierung mit Mandate Research
