---
title: "Ungereimtheiten-Report (2026-04-08)"
type: analysis
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_DATABASE_SCHEMA_v1_2.md", "ARK_BACKEND_ARCHITECTURE_v2_4.md", "ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_1.md", "ARK_KANDIDATENMASKE_INTERACTIONS_v1_2.md", "ARK_STAMMDATEN_EXPORT_v1_2.md"]
tags: [analysis, inconsistencies, decisions, schema-delta]
---

# Ungereimtheiten-Report

Systematische Prüfung aller Quellen auf Widersprüche. Stand 2026-04-08.

## Entschieden ✅

### 1. fact_vacancies ist deprecated

**Entscheidung:** `fact_vacancies` wird gelöscht. Alles migriert nach `fact_jobs` mit `confirmation_status` ('Vakanz' / 'Bestätigt').

**Noch zu tun in den Quelldokumenten:**
- [ ] DB Schema v1.2: `fact_vacancies` Tabelle entfernen, neue Spalten auf `fact_jobs` dokumentieren, `v_open_vacancies` View anpassen
- [ ] Backend Architecture v2.4: Vacancies-Modul entfernen, Endpoints auf Jobs umleiten, convert-to-job Flow → confirm-Job Flow
- [ ] Gesamtsystem-Übersicht v1.2: Abschnitt 5.2 (Vakanzen) als Sub-Konzept von Jobs formulieren

### 2. Account hat 11 Tabs + 1 konditional

**Entscheidung:** Account Interactions v0.1 ist massgebend.

| Quelle | Stand | Aktion |
|--------|-------|--------|
| Gesamtsystem v1.2 | Sagt "10 Tabs" | Aktualisieren auf "11 + 1 konditional" |
| Frontend Freeze v1.9 | 10 Tabs, andere Struktur | Aktualisieren: +Profil & Kultur, +Prozesse, +Reminders, Organigramm+Teamrad→Organisation, Firmengruppe→konditional |

### 3. Wechselmotivation-Benennung

**Entscheidung:** DB CHECK Constraint ist kanonisch. Wiki korrigiert.

| # | Kanonisch (DB) |
|---|---------------|
| 5 | Wechselmotivation spekulativ |
| 6 | Wechselt gerade intern & will abwarten |

### 4. DB Schema folgt Interactions

**Entscheidung:** Wenn Interactions-Specs und DB Schema sich widersprechen, gilt die Interactions-Spec. Das DB Schema wird nachgezogen. Das wird bei weiteren Entity-Interactions (Mandate, Prozesse etc.) noch öfter passieren.

---

## Schema-Deltas aus Account Interactions v0.1

Folgende Änderungen an `ARK_DATABASE_SCHEMA_v1_2.md` sind ausstehend:

### 7 neue Tabellen

| Tabelle | Zweck |
|---------|-------|
| `fact_account_culture_analysis` | AI-Kulturanalyse (JSONB, versioniert) |
| `fact_account_culture_scores` | 6 Kultur-Dimensionen × Account × Version |
| `dim_culture_dimensions` | Master Data: 6 Kultur-Dimensionen |
| `fact_account_temperature` | Hard-Rule + Score Breakdown |
| `dim_location_types` | HQ, Niederlassung |
| `fact_account_org_positions` | Stellenplan (besetzt/vakant/geplant) |
| `bridge_mitarbeiter_roles` | Multi-Role Bridge (existiert evtl. schon) |

### Breaking Changes an bestehenden Tabellen

| Tabelle | Änderung | Risiko |
|---------|----------|--------|
| `dim_account_contacts` | **15 Personen-Spalten entfernt** (→ leben auf dim_candidates_profile) | HOCH |
| `dim_account_contacts` | `candidate_id` wird effektiv NOT NULL | HOCH |
| `fact_account_locations` | 5 Spalten entfernt, location_type → FK | MITTEL |
| `dim_accounts` | +growth_rate_3y_pct, +revenue_last_year_chf | NIEDRIG |
| `fact_jobs` | +8 Spalten (confirmation_status, source, owner_am etc.) | NIEDRIG |
| `fact_vacancies` | **GELÖSCHT** | HOCH |

---

## Offene Spezifikationen

### Account Interactions v0.1

| Item | Status | Details |
|------|--------|---------|
| Tab 7: Mandate | ⚠️ In Arbeit | 6 offene Fragen |
| Tab 8: Prozesse | 📋 Platzhalter | "Analog Kandidat Tab 6" |
| Tab 9: History | 📋 Platzhalter | "1:1 Kandidat Tab 7" |
| Tab 10: Dokumente | 📋 Platzhalter | "1:1 Kandidat Tab 8" |
| Tab 11: Reminders | 📋 Platzhalter | "1:1 Kandidat Tab 10" |
| Firmengruppe (konditional) | 📋 Offen | Noch zu spezifizieren |

### Fehlende Interactions-Specs (andere Entities)

| Entity | Interactions-Spec | Status |
|--------|-------------------|--------|
| [[kandidat]] | v1.2 | ✅ Vollständig |
| [[account]] | v0.1 | ⚠️ Teilweise (Tabs 1-6 fertig) |
| [[job]] | — | ❌ Fehlt komplett |
| [[mandat]] | — | ❌ Fehlt komplett |
| [[prozess]] | — | ❌ Fehlt komplett |

Erwartung: Jede weitere Interactions-Spec wird Schema-Deltas erzeugen die ins DB Schema eingearbeitet werden müssen.

---

## Entschieden ✅ (Runde 2)

### 5. Inactive-Trigger: NUR Alter >60

**Entscheidung:** Cold >6 Monate löst NICHT Inactive aus. Inactive ist ein extrem heikler Status — Kandidat wird nie mehr kontaktiert. Nur weil jemand lange nicht kontaktiert wurde, heisst das nicht, dass er nicht mehr spannend sein kann.

**Korrektur nötig in Quelldokumenten:**
- [ ] Gesamtsystem-Übersicht v1.2: "Auto: Alter >60 oder Cold >6 Monate" → nur "Alter >60"
- [ ] Stammdaten-Export v1.2: "Alter > 60 oder Cold > 6 Monate (täglicher Job)" → nur "Alter > 60"
- Backend Architecture v2.4: War bereits korrekt (nur Alter >60)

### 6. Refresh-Trigger: Nur nach CV Expected

**Entscheidung:** NIC/Dropped/Ghosting löst Refresh nur aus wenn der Kandidat bereits einen CV Expected Eintrag hatte und danach absagt. Unabhängig ob Mandat oder Erfolgsbasis.

**Korrektur nötig in Quelldokumenten:**
- [ ] Gesamtsystem-Übersicht v1.2: "NIC, Dropped" generell → "NIC/Dropped/Ghosting nach CV Expected"
- [ ] Stammdaten-Export v1.2: Gleiche Einschränkung ergänzen

### 7. Rebriefing löst KEIN Premarket aus

**Entscheidung:** Wenn ein Kandidat bereits in Active Sourcing oder höher ist, bleibt er dort. Premarket wird nur beim ersten Briefing getriggert (Check/Refresh → Premarket).

### 8. Mandat-Status: Mixed Language bereinigen

**Empfehlung:** DB CHECK Constraint mischt Deutsch und Englisch (`Entwurf`, `Active`, `Abgelehnt`, `Completed`, `Cancelled`). Sollte auf **durchgehend Deutsch** oder **durchgehend Englisch** umgestellt werden.

> **Deine Entscheidung nötig:** Alles Deutsch (`Entwurf`, `Aktiv`, `Abgelehnt`, `Abgeschlossen`, `Abgebrochen`) oder alles Englisch (`Draft`, `Active`, `Rejected`, `Completed`, `Cancelled`)?

### 9. Account Interactions v0.1: Stale Reference

Account_Manager in rolle_type CHECK: Account Interactions sagt "muss hinzugefügt werden", aber DB Schema v1.2 hat es bereits. Account Interactions war gegen ältere Schema-Version geschrieben. Kein Handlungsbedarf — nur Dokumentation veraltet.

---

## Phase 1.5/2 Features (Account, geparkt)

- Account Temperature konfigurierbar
- Auto-Geocoding Standorte
- Karten-Visualisierung Standorte
- Kulturprofil Fragebogen-Modus + voll-AI Switch
- Account-Logo via externe API
- Konfigurierbare Spalten Kontakte
- Customer Portal Stellenplan
- Cross-Account Abteilungs-Auswertung
- Mandate-Templates Stammdaten
- Diff-Ansicht Kulturprofil-Versionen

## Related

- [[datenbank-schema]] — Muss aktualisiert werden
- [[backend-architektur]] — Vacancies-Modul betroffen
- [[account]] — 11+1 Tabs mit Spec-Status
- [[job]] — fact_vacancies deprecated
- [[kontakt-kandidat-regel]] — Treibt die dim_account_contacts Änderungen
