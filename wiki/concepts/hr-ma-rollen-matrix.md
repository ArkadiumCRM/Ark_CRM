---
title: "HR · MA-Rollen-Matrix (Arbeitsrecht-Lens)"
type: concept
created: 2026-04-19
updated: 2026-04-19
sources: [
  "hr-arbeitsvertraege.md",
  "hr-provisionsvertraege.md",
  "hr-stellenbeschreibung-progressus.md"
]
tags: [hr, phase-3, ma-rolle, consultant, researcher, candidate-manager, account-manager, team-leader, progressus]
---

# HR · MA-Rollen-Matrix

Überblick aller MA-Rollen im Arkadium-Vertragswerk, **aus Arbeitsrechts-/Vertrags-Sicht**. Ergänzt Memory `project_arkadium_roles_2026.md` (Commission-Engine-Sicht) und Memory `project_commission_model.md` (Rollen-Historie).

## Unterscheidung wichtig

| Blickwinkel | Was wird abgebildet |
|-------------|---------------------|
| **Arbeitsvertrag (Progressus)** | Funktion zum Stellenantritt (z.B. "Consultant"). Selten geändert. |
| **Provisionsvertrag (Praemium Victoria)** | Rolle im Geschäftsjahr (z.B. "Team Leader REM"). Jährlich neu. |
| **Commission-Engine · Rollen-Historie** | Rolle zum Zeitpunkt eines Deals (CM/AM/Team Leader). Pro Vermittlung. |

## Rollen-Übersicht (Vertrag-Lens)

| Rolle | Arbeitsvertrag-Variante | Karenzentschädigung | Zeichnungs-Berechtigung | Budget | Signator-Co |
|-------|------------------------|---------------------|-------------------------|--------|-------------|
| **Research Analyst & Junior Consultant** | Researcher (inline oder Praemium) | CHF 350/Mt | Nein | Kein eigenes | Stefano Papes (Head) |
| **Consultant** | Consultant-Template | CHF 500/Mt | Nein (Default) | Individuelle Ziele | Stefano Papes / Peter Wiederkehr (Head) |
| **Candidate Manager (CM)** | Provision `Candidate Manager` | Fix + Variabel | Nein | Individuelle Ziele (~CHF 320k Architecture) | Head-of-Department |
| **Account Manager (AM)** | Provision (gleiche Vorlage) | Fix + Variabel | Teil-Zeichnung (Rechnungen, Kundenofferten) | Individuelle Ziele | Head-of-Department |
| **Team Leader** (z.B. REM) | Provision `Team Leader` | Fix + Variabel | Erweitert | **Team-Budget** (z.B. CHF 850k REM inkl. Unterstellte) | Founder & Partner |
| **Head-of-Department** (z.B. Head of Civil Engineering & Building Technology) | Individuell verhandelt | — | Voll | Geschäftsbereich-Budget | Founder & Partner |
| **Founder & Partner** | Individuell verhandelt | — | Voll (GL) | GL-Budget | — |

## Konkrete Namens-Referenzen aus Templates

- **Nenad Stoparanovic** — Partner & Founder · Co-Signator aller Arbeitsverträge · GL-Ermessen bei Provisionen
- **Peter Wiederkehr** — Head of Civil Engineering & Building Technology · Signator für REM/Bau-Sparten
- **Stefano Papes** — Head of Architecture & Real Estate · Signator ARC-Sparte
- **Sonja Bee Spiess** — Mitarbeiter-Beispiel (Reglement-Co-Signatur)
- **Hanna van den Bosch** — MA-Beispiel (Progressus Consultant)
- **Tatjana Petrovic** — MA-Beispiel (Verwarnung/Annullierung)
- **Aysun Yilmaz** · **Raphael Benjamin** — REM-Team (unterstellt Team Leader REM)

## MA-Typ × Provisions-Berechtigung (Praemium Victoria §4)

| Bei einem Vertragsabschluss | Rolle zulässig? |
|-----------------------------|-----------------|
| Candidate Manager (Halbpunkt Kandidat) | ✓ |
| Account Manager (Halbpunkt Kunde) | ✓ |
| Team Leader (Teambudget) | ✓ |
| Researcher | ✗ **nicht zusätzlich zu CM/AM/TL** |
| Consultant (ohne CM/AM-Rolle) | ✗ (muss CM oder AM sein) |

**Sonderregel §5.3:** Nach **3 Monaten** Übertritt Researcher → Consultant entfällt Anspruch auf Researcher-Vermittlungen.

## Tätigkeits-Deltas (Progressus)

### Nur Consultant hat

- **Debitorenmanagement** (eigene Platzierungen/Mandate)
- **On-/Offboarding-Steuerung** beim Kunden + Kadermitarbeiter
- AGB-Vorstellung + Individualverhandlungen (mit GL-Rücksprache)
- Prozess-Journal + Fazitbericht
- Bedarfsbesprechungen + Konditionenverhandlungen
- Ansprache GL/Entscheidungsträger aktive + potenzielle Kunden
- Beratung Inserations-Management + E-Recruiting
- Referenz-Interviews (systematisch)

### Researcher konzentriert auf

- Identifikation · Recherche · Profiling · Ansprache → **Ident erstellen**
- Eignungsabklärungen (Hunt Calls)
- Career Transition + Leadership Coaching
- Arbeitsmarkt-Analyse
- Digital Data Management

### Team Leader (zusätzlich zu Consultant/AM)

- Rekrutierung + Anstellung neuer MA (im eigenen Team)
- Einführung + Schulung (Arkadium-Methode)
- Team-Ziel-Verantwortung (inkl. unterstellte Budgets)
- Massnahmen bei Ist-Soll-Abweichung
- Disziplinarische Führung

## Vorgesetzten-Matrix (Organigramm-Seeds)

```
Founder & Partner (Nenad Stoparanovic)
 │
 ├─ Head of Architecture & Real Estate (Stefano Papes)
 │   ├─ Team Leader ARC (falls separat)
 │   │   └─ Consultants ARC
 │   ├─ Team Leader REM (xxx)
 │   │   ├─ Aysun Yilmaz (CM/AM REM)
 │   │   └─ Raphael Benjamin (CM/AM REM)
 │   └─ Research Analysts
 │
 └─ Head of Civil Engineering & Building Technology (Peter Wiederkehr)
     ├─ Team Leader ING
     ├─ Team Leader TEC
     ├─ Consultants
     └─ Research Analysts
```

(Realer Stand 2026 siehe Memory `project_arkadium_roles_2026.md`.)

## Implikation fürs HR-Tool

Plan v0.1 §4.3 nennt 6 Rollen + 3 neue HR-Rollen (HR-Manager · Team-Lead · Employee-Self). Ergänzt um:

### `dim_job_descriptions` (neue Tabelle — siehe [[hr-stellenbeschreibung-progressus]])

```sql
-- Seed für Arkadium:
INSERT INTO dim_job_descriptions (code, name_de, bereich, sparte, signing_authority, default_pensum)
VALUES
  ('consultant', 'Consultant', 'Executive & Professional Search', 'ARC/REM/ING/TEC', false, 100),
  ('research_analyst', 'Research Analyst & Junior Consultant', 'Executive & Professional Search', 'ARC/REM/ING/TEC', false, 100),
  ('team_leader_rem', 'Team Leader Real Estate Management', 'Kernbusiness', 'REM', true, 100),
  ('team_leader_arc', 'Team Leader Architecture', 'Kernbusiness', 'ARC', true, 100),
  ('team_leader_ing', 'Team Leader Civil Engineering', 'Kernbusiness', 'ING', true, 100),
  ('team_leader_tec', 'Team Leader Building Technology', 'Kernbusiness', 'TEC', true, 100),
  ('head_of_architecture_rem', 'Head of Architecture & Real Estate', 'Kernbusiness', 'ARC+REM', true, 100),
  ('head_of_civ_bldg', 'Head of Civil Engineering & Building Technology', 'Kernbusiness', 'ING+TEC', true, 100),
  ('founder_partner', 'Partner & Founder', 'GL', NULL, true, 100),
  ('backoffice', 'Backoffice', 'Operations', NULL, false, 100),
  ('hr_manager', 'HR-Manager', 'GL-Assistenz/HR', NULL, true, NULL);
```

### Rolle-zu-Rolle-Wechsel (Versionierung)

Wenn Researcher → Consultant (Beförderung):
- Neuer Arbeitsvertrag mit Funktion Consultant (oder Vertragsanpassung)
- Karenzentschädigung CHF 350 → CHF 500
- Neue Stellenbeschreibung "Progressus" erhalten + signiert
- Neuer Provisionsvertrag "Praemium Victoria" (eigene Ziele statt CHF 500/Vermittlung)
- **§5.3-Clock** startet: 3 Mt bis alte Researcher-Vermittlungen verfallen
- Audit-Trail in `fact_lifecycle_transitions` (Plan §6.2) + neu `fact_role_transitions`

### `fact_role_transitions` (neue Tabelle)

```sql
CREATE TABLE fact_role_transitions (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  from_role TEXT NOT NULL,
  to_role TEXT NOT NULL,
  effective_date DATE NOT NULL,
  reason TEXT CHECK (reason IN (
    'promotion', 'lateral_move', 'demotion', 'specialization', 'initial_assignment'
  )),
  new_karenzentschaedigung_chf_mt NUMERIC(8,2),
  new_contract_id UUID REFERENCES fact_employment_contracts(id),
  provision_grace_period_months INT DEFAULT 3,    -- §5.3-Regel Praemium Victoria
  approved_by UUID REFERENCES dim_mitarbeiter(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

## Related

- [[hr-vertragswerk]] · [[hr-provisionsvertraege]] · [[hr-stellenbeschreibung-progressus]]
- Memory `project_arkadium_roles_2026.md` (aktuelle MA-Liste + Rollen)
- Memory `project_commission_model.md` (Commission-Engine v1.0, Rollen-Historie)
- [[hr-schema-deltas-2026-04-19]]
