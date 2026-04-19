---
title: "HR · Konkurrenz- + Abwerbeverbot + Karenzentschädigung"
type: concept
created: 2026-04-19
updated: 2026-04-19
sources: [
  "hr-arbeitsvertraege.md",
  "hr-kuendigung-aufhebung.md"
]
tags: [hr, phase-3, konkurrenzverbot, abwerbeverbot, karenzentschaedigung, konventionalstrafe, or-340, geheimhaltung]
---

# HR · Konkurrenz- + Abwerbeverbot (18 Monate Deutschschweiz)

Zentrale Post-Vertrags-Klauseln in jedem Arkadium-Arbeitsvertrag (Ziffer 9). **Schutzgrund:** USP + Methode + Marktposition + Firmenkunden gemäss Academy (§4 Generalis Provisio).

## §9.1 Ausgangslage (Rechtfertigung)

> "Die Arkadium besteht darauf ihren USP, ihre Methode und das vermittelte Fachwissen, ihre Marktposition und Firmenkunden zu schützen, weshalb ein Konkurrenzverbot und ein Abwerbeverbot für die Ausübung der Position zwingend ist."

Rechtsgrundlage: **Art. 340 ff. OR** (Konkurrenzverbot) + **Art. 321a OR** (Treuepflicht) + **Art. 340b Abs. 3 OR** (Realexekution).

## §9.2 Konkurrenzverbot

### Parameter

| Dimension | Wert |
|-----------|------|
| **Dauer** | **18 Monate nach Beendigung AV** |
| **Gebiet** | **Deutschschweiz** |
| **Branche** | Personalvermittlung · -beratung · Executive Search · HR Solution & HR Consulting in Bauhaupt-/Baunebengewerbe · Architecture · Civil Engineering · Real Estate Management · Building Technology & Energy Environmental · Personalverleih in Bauhaupt-/Baunebengewerbe |

### Verbotene Handlungen (nicht abschliessend)

1. Kontakt mit Kunden oder Kandidaten, mit denen MA während AV befasst war
2. Eingreifen in geplante/laufende Rekrutierungsprojekte + Mandate
3. Eingreifen in Outsourcing-Projekte + Lieferantenkonsolidierungen
4. Kontakt mit Kandidaten aus Arkadium-Expertenpool (CRM-DB)
5. **Einführung der gelernten Suchstrategie/Methode** bei anderem Dienstleister in Bau/Immobilien/Architektur

### Erlaubt

- Personalvermittlung/Personalverleih in **anderen Branchen** (Logistik · Gesundheit · Legal · etc.)

### Nicht erlaubt

- Internes HR bei Kunde in Arkadium-Branche **mit Arkadium-Methode**

## §9.3 Abwerbeverbot

### Parameter

- **Dauer: 18 Monate nach Beendigung AV**
- **Während AV + post-AV**

### Geschützte Personen

Alle Arbeitnehmer, Kandidaten, Kunden, Geschäftspartner der Arkadium.

### Kunden-Definition (§9.3 Abs. 2)

Natürliche + juristische Personen die:
- In ungekündigtem Mandatsverhältnis zu Arkadium stehen, **oder**
- Innert letzter 2 Kalenderjahre Leistungen bezogen haben, **oder**
- Innerhalb letzter 24 Monate Offerte von Arkadium erhalten haben, **oder**
- Anfrage an Arkadium gesandt haben, **oder**
- Kandidaten-Vorstellung von Arkadium erhalten haben

## §9.4 Konventionalstrafen + Schadenersatz

### Nachvertraglich

| Verletzung | Strafe |
|-----------|--------|
| **Konkurrenzverbot** (§9.2) | Höhe der letzten **12 Bruttomonatslöhne inkl. Provisionen/Spesen/Gratifikationen**, **mindestens CHF 80'000** |
| **Abwerbeverbot** (§9.3) | **CHF 80'000 pro Zuwiderhandlung** |

### Zusätzlich

- Ersatz weiteren Schadens (Art. 340b Abs. 3 OR)
- **Realexekution** (Beseitigung des rechtswidrigen Zustands)
- Bezahlung entbindet nicht von Einhaltungs-Pflicht

## §10 Disziplinarstrafen während AV

| Verletzung | Strafe |
|-----------|--------|
| Konkurrenzierung (§9.2-Definition) während AV | **CHF 20'000** |
| Abwerbung (§9.3-Definition) während AV | **CHF 10'000** |
| Nebentätigkeit ohne Zustimmung (§3.5.3 GP) | **CHF 3'000** |
| Diffamierende Äusserung | **CHF 5'000** |
| Geschäftsgeheimnis-Verletzung | **CHF 20'000** |
| Andere Treuepflichtverletzungen | Art. 321e OR (Schadenersatz) |

**Zusätzlich zu Strafen:** Schadenersatzansprüche bleiben vorbehalten.

## §11 Nachvertragliche Geheimhaltung

- Pflicht zur Verschwiegenheit während **und nach** AV
- Kunden-/Mitarbeiterdaten = Arkadium-Eigentum
- Kontrollen (DB, Mobiltelefon) ohne Vorankündigung zulässig
- Rückgabe aller Akten bei Beendigung
- **Konventionalstrafe CHF 20'000/Verletzung** + Strafrecht UWG

## Karenzentschädigung

**Name:** "Karenzentschädigung" (CHF 500 Consultant · CHF 350 Researcher) — monatlich brutto zusätzlich zum Bruttobasisgehalt während AV gezahlt.

**Funktion:** Kompensation für Konkurrenzverbot-Einschränkung. Teil des monatlichen Gehalts, nicht nachträglich ausgezahlt.

**Achtung — NICHT zu verwechseln mit:**
- Konkurrenzverbots-Entschädigung im Sinne Art. 340a Abs. 2 OR (nachvertragliche Zahlung falls Pflichtwidrigkeit) — existiert hier nicht separat
- Sozialversicherungs-Karenztage (eine andere Definition)

## Verrechnung

**§9.4 Abs. 4:** Arkadium ist berechtigt, Schadenersatz-/Disziplinar-/Konventionalstrafen-Forderungen **unverzüglich mit offenen Lohnforderungen zu verrechnen**.

## Schema-Implikationen für HR-Tool

Plan v0.1 §6.2 hat:
```sql
konkurrenzverbot_monate INT DEFAULT 0,
konkurrenzverbot_radius_km INT DEFAULT 0,
konkurrenzverbot_entschaedigung_chf NUMERIC(10,2) DEFAULT 0,
```

**Nicht ausreichend** — Arkadium-Realität:

```sql
-- Erweiterung fact_employment_contracts:
ALTER TABLE fact_employment_contracts ADD COLUMN IF NOT EXISTS
  konkurrenzverbot_monate INT DEFAULT 18,
  konkurrenzverbot_region TEXT DEFAULT 'Deutschschweiz',
  konkurrenzverbot_branche_scope TEXT[],                   -- ['bau_hauptgewerbe', 'bau_nebengewerbe', 'architecture', ...]
  konkurrenzverbot_konventionalstrafe_min_chf NUMERIC(10,2) DEFAULT 80000,
  konkurrenzverbot_konventionalstrafe_formula TEXT DEFAULT '12 Bruttomonatslöhne inkl. Provisionen/Spesen',
  abwerbeverbot_monate INT DEFAULT 18,
  abwerbeverbot_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 80000,
  karenzentschaedigung_chf_mt NUMERIC(8,2),               -- 500 Consultant · 350 Researcher
  nachvertragliche_geheimhaltung_konventionalstrafe_chf NUMERIC(10,2) DEFAULT 20000;

-- Neue Tabelle: Disziplinarstrafen-Katalog + Events
CREATE TABLE dim_disciplinary_penalty_types (
  id UUID PRIMARY KEY,
  code TEXT UNIQUE,
  name_de TEXT NOT NULL,
  during_employment BOOLEAN DEFAULT true,
  post_employment BOOLEAN DEFAULT false,
  default_amount_chf NUMERIC(10,2),
  legal_ref TEXT                                           -- 'OR 321a', 'OR 340b', ...
);

-- Seeds:
-- konkurrenzierung_during_av · CHF 20000 · OR 321a
-- abwerbung_during_av · CHF 10000
-- nebentaetigkeit_unauthorized · CHF 3000
-- diffamation · CHF 5000
-- geheimhaltung_verletzung · CHF 20000
-- konkurrenzverbot_post_av · min CHF 80000 (Formel)
-- abwerbeverbot_post_av · CHF 80000 / Zuwiderhandlung
-- geheimhaltung_post_av · CHF 20000

CREATE TABLE fact_disciplinary_incidents (
  id UUID PRIMARY KEY,
  mitarbeiter_id UUID REFERENCES dim_mitarbeiter(id),
  penalty_type_id UUID REFERENCES dim_disciplinary_penalty_types(id),
  incident_date DATE,
  reported_by UUID,
  reported_at TIMESTAMPTZ DEFAULT now(),
  evidence_document_urls TEXT[],
  penalty_amount_chf NUMERIC(10,2),
  status TEXT DEFAULT 'investigation' CHECK (status IN (
    'investigation', 'confirmed', 'dismissed', 'paid', 'contested_in_court'
  )),
  offset_against_salary BOOLEAN DEFAULT false,
  offset_month DATE,
  notes TEXT
);
```

## Post-Austritt-UI

**Kandidat-Profil-Tab "Konkurrenzverbot-Status":**
- Ausgetretene MA: 18-Mt-Countdown seit Austrittsdatum
- Automatische Alerts wenn Aktivitäten mit Kandidaten/Kunden aus Arkadium-Pool detektiert werden (z.B. LinkedIn-Monitoring)
- Audit-Trail für eventuelle Gerichtsverfahren

## Related

- [[hr-arbeitsvertraege]] · [[hr-kuendigung-aufhebung]]
- [[hr-reglemente]] §3.5.3 Nebenbeschäftigung + §3.6 Sorgfaltspflicht
- [[hr-schema-deltas-2026-04-19]]
- [[direkteinstellung-schutzfrist]] (unterschiedliches Konzept — AGB §6, 12/16 Mt, schützt Arkadium als Unternehmen vor Kunden-Direkteinstellung)
