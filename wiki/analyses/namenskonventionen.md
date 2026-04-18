---
title: "Namenskonventionen — Kanonische Benennungen"
type: analysis
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_DATABASE_SCHEMA_v1_2.md", "ARK_STAMMDATEN_EXPORT_v1_2.md", "ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md", "ARK_FRONTEND_FREEZE_v1_9.md", "ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md"]
tags: [analysis, naming, conventions, consistency, audit]
---

# Namenskonventionen — Kanonische Benennungen

Einheitliche Benennung über alle Dokumente und Code hinweg. Bei Widersprüchen gilt diese Seite.

## Grundregel

> Schweizer Domain-Begriffe auf **Deutsch**, generische/technische Begriffe auf **Englisch**. Keine Umlaute in DB-Feldnamen. Der **DB CHECK Constraint** ist die Single Source of Truth für gespeicherte Werte.

---

## Rollen

| DB-Key (gespeichert) | Anzeige (UI) | Kürzel |
|----------------------|-------------|--------|
| `Admin` | Admin | Admin |
| `Candidate_Manager` | Candidate Manager | CM |
| `Account_Manager` | Account Manager | AM |
| `Researcher` | Research Analyst | RA |
| `Head_of` | Head of Department | HoD |
| `Backoffice` | Backoffice | BO |
| `Assessment_Manager` | Assessment Manager | — |
| `ReadOnly` | Read Only | RO |

> [!warning] Deprecated
> `dim_mitarbeiter.rolle_type` ist deprecated. Neue Wahrheit: `dim_roles` + `bridge_mitarbeiter_roles`.

---

## Mandat-Status

| DB CHECK (gespeichert) | Anzeige (UI) |
|------------------------|-------------|
| `Entwurf` | Entwurf |
| `Active` | Aktiv |
| `Abgelehnt` | Abgelehnt |
| `Completed` | Abgeschlossen |
| `Cancelled` | Abgebrochen |

> [!warning] Mixed Language im DB CHECK
> Der CHECK mischt DE (`Entwurf`, `Abgelehnt`) und EN (`Active`, `Completed`, `Cancelled`). Bleibt vorerst so — aber Display-Texte verwenden **immer Deutsch**. Alle Dokumente müssen die DB-Werte referenzieren wenn sie den gespeicherten Wert meinen.

**Inkonsistenzen in Quelldokumenten:**
- Gesamtsystem + Frontend Freeze schreiben "Aktiv" / "Abgeschlossen" / "Abgebrochen" ohne klarzustellen dass der DB-Wert anders lautet
- [ ] Quelldokumente ergänzen: DB-Wert ≠ Anzeige-Wert

---

## Kandidaten-Stages

| DB CHECK (gespeichert) | Anzeige (UI) |
|------------------------|-------------|
| `Check` | Check |
| `Refresh` | Refresh |
| `Premarket` | Premarket |
| `Active Sourcing` | Active Sourcing |
| `Market Now` | Market Now |
| `Inactive` | Inactive |
| `Blind` | Blind |
| `Datenschutz` | Datenschutz |

Konsistent — kein Handlungsbedarf.

---

## Prozess-Stages

| DB CHECK (gespeichert) | Anzeige (UI, Deutsch) |
|------------------------|-----------------------|
| `Exposé` | Exposé |
| `CV Sent` | CV Sent |
| `TI` | Telefoninterview |
| `1st` | 1. Interview |
| `2nd` | 2. Interview |
| `3rd` | 3. Interview |
| `Assessment` | Assessment |
| `Offer` | Angebot |
| `Placement` | Platzierung |

**Entscheidung:** DB-Wert wird auf `Exposé` (mit Akzent) korrigiert — einheitlich überall.
- [ ] DB CHECK für process_stages anpassen: `'Expose'` → `'Exposé'`

---

## Prozess-Status

Durchgehend Englisch — konsistent:
`Open`, `On Hold`, `Rejected`, `Placed`, `Stale`, `Closed`, `Cancelled`, `Dropped`

---

## Activity-Type-Kategorien

| DB CHECK (gespeichert) | Verwendung in Docs |
|------------------------|--------------------|
| `Kontaktberührung` | ✅ Konsistent |
| `Erreicht` | ✅ Konsistent |
| `Emailverkehr` | ✅ Konsistent |
| `Messaging` | ✅ Konsistent |
| `Interviewprozess` | ✅ Konsistent |
| `Placementprozess` | ✅ Konsistent |
| `Refresh Kandidatenpflege` | ✅ "Refresh" als Kurzform im UI erlaubt |
| `Mandatsakquise` | ✅ Konsistent |
| `Erfolgsbasis` | ✅ Konsistent |
| `Assessment` | ✅ Konsistent |
| `System` | ✅ Konsistent |

**"Refresh" als UI-Kurzform erlaubt.** DB-Wert bleibt `Refresh Kandidatenpflege`, Filter-Query mappt intern.

---

## Dokument-Labels

| DB CHECK (gespeichert) | Varianten in Docs | Problem |
|------------------------|-------------------|---------|
| `Original CV` | ✅ Konsistent | — |
| `ARK CV` | ✅ Konsistent | — |
| `Abstract` | ✅ Konsistent | — |
| `Exposé` | ✅ Überall mit Akzent | DB CHECK anpassen: `Expose` → `Exposé` |
| `Arbeitszeugnis` | ✅ Konsistent | — |
| `Diplom` | ✅ Konsistent | — |
| `Zertifikat` | ✅ Konsistent | — |
| `Mandat-Report` | ✅ Mit Hyphen | DB CHECK anpassen: `Mandat Report` → `Mandat-Report` |
| `Assessment` | ✅ Kurzform | DB CHECK anpassen: `Assessment-Dokument` → `Assessment` |
| `Mandatsofferte unterschrieben` | ✅ Konsistent | — |
| `Sonstiges` | ✅ Konsistent | — |
| `Vertrag` | ✅ Hinzufügen | DB CHECK erweitern |

**Entfernt:** `Schriftliche GO` (ist ein Email/History-Eintrag, kein Dokument), `Foto` (wird über Avatar hochgeladen, kein Dokument-Label)

**Korrekturen am DB CHECK (document_label):**
- [ ] `Expose` → `Exposé`
- [ ] `Mandat Report` → `Mandat-Report`
- [ ] `Assessment-Dokument` → `Assessment`
- [ ] `Vertrag` hinzufügen
- [ ] `Schriftliche GO` und `Foto` NICHT hinzufügen (kein Dokument-Label)

---

## Standort-Typen

| DB CHECK (gespeichert) | Account Interactions v0.1 | Problem |
|------------------------|---------------------------|---------|
| `HQ` | `HQ` | ✅ |
| `Branch` | `Niederlassung` | ❌ Verschiedene Sprache |
| `Factory` | *(nicht erwähnt)* | ❌ Fehlt in Interactions |
| `Office` | *(nicht erwähnt)* | ❌ Fehlt in Interactions |

**Entscheidung:** Nur 2 Typen: `HQ` und `Niederlassung`. Factory und Office werden nicht benötigt.

- [ ] DB CHECK anpassen: `'HQ','Branch','Factory','Office'` → `'HQ','Niederlassung'`
- [ ] Oder via `dim_location_types` Tabelle (wie Account Interactions vorschlägt)

---

## Wechselmotivation

Kanonisch (DB CHECK):

| # | Gespeicherter Wert |
|---|-------------------|
| 1 | Arbeitslos |
| 2 | Will/muss wechseln |
| 3 | Will/muss wahrscheinlich wechseln |
| 4 | Wechselt bei gutem Angebot |
| 5 | Wechselmotivation spekulativ |
| 6 | Wechselt gerade intern & will abwarten |
| 7 | Will absolut nicht wechseln |
| 8 | Will nicht mit uns zusammenarbeiten |

Konsistent — Gesamtsystem kürzt leicht ab (dokumentiert, kein Problem).

---

## Zusammenfassung: DB CHECK Korrekturen

Alle Entscheidungen getroffen. Folgende Anpassungen am DB Schema sind nötig:

### Prozess-Stages
- [ ] `'Expose'` → `'Exposé'`

### Dokument-Labels
- [ ] `'Expose'` → `'Exposé'`
- [ ] `'Mandat Report'` → `'Mandat-Report'`
- [ ] `'Assessment-Dokument'` → `'Assessment'`
- [ ] `'Vertrag'` hinzufügen
- ~~`Schriftliche GO`~~ — kein Dokument (ist Email/History)
- ~~`Foto`~~ — kein Dokument (ist Avatar-Upload)

### Location Types
- [ ] `'HQ','Branch','Factory','Office'` → `'HQ','Niederlassung'`

### Keine Änderung nötig
- Mandat-Status: Mixed Language bleibt, Display-Mapping dokumentiert
- Activity-Kategorien: "Refresh" als UI-Kurzform erlaubt
- Kandidaten-Stages: Konsistent
- Prozess-Status: Konsistent

## Related

- [[datenbank-schema]] — CHECK Constraints als Source of Truth
- [[berechtigungen]] — Rollen-Definitionen
- [[stammdaten]] — Master Data Katalog
- [[ungereimtheiten-report]] — Entscheidungs-Log
