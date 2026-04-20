## 1. LEGAL-FRAMEWORK

### 1.1 Primärquelle: ArG Art. 46 (Auskunfts- und Aufzeichnungspflicht)
**Wortlaut** (Bundesgesetz über die Arbeit in Industrie, Gewerbe und Handel, SR 822.11):
- Abs. 1: „Der Arbeitgeber hat den Vollzugs- und Aufsichtsbehörden alle Verzeichnisse oder anderen Unterlagen zur Verfügung zu halten, aus denen die für den Vollzug dieses Gesetzes und seiner Verordnungen erforderlichen Angaben ersichtlich sind."
- Abs. 2: „Die Unterlagen sind mindestens während fünf Jahren nach Ablauf ihrer Gültigkeit aufzubewahren" (konkretisiert durch ArGV 1 Art. 73 Abs. 2).

**Produktimplikation**: `audit_trail JSONB` und `retention_until DATE` auf allen Fact-Tables. Soft-Delete mit 5-Jahres-Sperre ab Vertragsende/Eintragsjahr. WORM-ähnliches Verhalten für `locked` Entries.

### 1.2 ArGV 1 Art. 73 (Normale Zeiterfassung)
Pflicht zur Erfassung folgender Angaben (Abs. 1 lit. a–h):
- Personalien des Arbeitnehmers
- Art der Tätigkeit, An- und Abreisedaten
- Die geleistete **tägliche und wöchentliche Arbeitszeit** inkl. Ausgleichs- und Überzeitarbeit sowie ihre Lage
- Gewährte wöchentliche Ruhe- oder Ersatzruhetage, soweit diese nicht regelmässig auf einen Sonntag fallen
- Lage und Dauer der **Pausen von einer halben Stunde und mehr**
- Betriebliche Abweichungen von Tages- oder Nachtarbeit
- Regelungen über Ausgleich bei Sonn-/Feiertagsarbeit
- Bewilligungen nach Art. 12 und 14 ArG

Abs. 2: Aufbewahrung **mindestens fünf Jahre** nach Ablauf der Gültigkeit.

### 1.3 ArGV 1 Art. 73a (Verzicht auf Zeiterfassung) — hier N/A
Kumulative Voraussetzungen:
- a) **grosse Autonomie** bei der Arbeit, Arbeitszeit mehrheitlich selbst festsetzbar
- b) **Bruttojahreslohn ≥ CHF 120'000** inkl. Boni (gekoppelt an UVG-Höchstverdienst)
- c) Verankerung in einem **GAV**, unterzeichnet von der **Mehrheit der repräsentativen Arbeitnehmerorganisationen** der Branche/des Betriebs; GAV regelt zusätzlich Gesundheitsschutz und spezifische Massnahmen zur Arbeitszeit
- d) **individuelle schriftliche Verzichtsvereinbarung** pro Arbeitnehmer, einseitig jährlich widerrufbar

**Warum N/A für diese Boutique**: Kein GAV vorhanden, Headhunting-Branche hat keinen branchenweiten GAV mit Mehrheitsgewerkschaft → Voraussetzung (c) strukturell nicht erfüllbar. Selbst bei Löhnen >120k ist Art. 73a juristisch verschlossen.

### 1.4 ArGV 1 Art. 73b (Vereinfachte Zeiterfassung) — hier relevant
Kumulative Voraussetzungen:
- Arbeitnehmer kann **Arbeitszeit zu einem namhaften Teil (>50%) selbst festsetzen**
- **Schriftliche kollektive Vereinbarung** zwischen Arbeitgeber und Arbeitnehmervertretung oder — in Betrieben **unter 50 Mitarbeitenden** — mit der **Mehrheit der Arbeitnehmenden** (→ hier bei 10 MA anwendbar)
- Erfasst wird **nur die geleistete tägliche Arbeitszeit** (kein Start/Ende nötig, kein Pausen-Detail)
- Bei Nacht-/Sonntagsarbeit **zusätzlich Anfang und Ende** der Einsätze
- Jährliches **Endgespräch** MA↔AG zur Belastung und Einhaltung

**Produktimplikation**: Konfigurations-Flag pro MA (`simplified_recording = true`); Template für Sozialpartner-Vereinbarung als Asset; Task-Generator für jährliches Endgespräch.

### 1.5 Höchstarbeitszeit (ArG Art. 9–12)
- **Art. 9**: 45 h/Woche für Büropersonal, technische und andere Angestellte, Verkaufspersonal in Grossbetrieben; 50 h für übrige Arbeitnehmer → Headhunting-Boutique fällt unter **45 h-Regime**
- **Art. 12**: Überzeit max. 2 h/Tag, Jahreslimit **170 h bei 45h-Woche** bzw. 140 h bei 50h-Regime
- **Art. 13**: 25% Lohnzuschlag auf Überzeit (Büropersonal: ab 61. Überzeitstunde/Jahr; ausgleichbar mit Freizeit gleicher Dauer innert 14 Wochen bei Einverständnis MA)

### 1.6 Ruhezeiten und Pausen (ArG Art. 15–22)
| Artikel | Regel |
|---|---|
| Art. 15 | Pausen: **15 min ab 5.5 h**, **30 min ab 7 h**, **60 min ab 9 h** Tagesarbeitszeit |
| Art. 15a | **Tägliche Ruhezeit mind. 11 h** zwischen zwei Arbeitstagen |
| Art. 16 | Nachtarbeit 23:00–06:00 Uhr, grundsätzlich verboten ohne Bewilligung |
| Art. 18 | **Sonntagsarbeit verboten** (Sa 23:00 – So 23:00), bewilligungspflichtig |
| Art. 20 | Ein ganzer freier Tag pro Woche, i.d.R. Sonntag |
| Art. 20a | Kantone können **max. 8 weitere Feiertage** + Bundesfeier den Sonntagen gleichstellen |
| Art. 21 | Wöchentliche Ruhezeit **35 h zusammenhängend** (Sonntag + angrenzende Nacht) |
| Art. 22 | Pausen und Ruhezeiten sind unabdingbar |

### 1.7 Überstunden vs. Überzeit (OR Art. 321c)
- **Überstunden** (OR 321c) = Arbeit über vertragliche Arbeitszeit hinaus, innerhalb der gesetzlichen Höchstarbeitszeit
- **Überzeit** (ArG 12/13) = Arbeit über gesetzliche Höchstarbeitszeit (45h/50h)
- OR 321c Abs. 2: Ausgleich durch Freizeit gleicher Dauer bei Einverständnis beider Seiten
- OR 321c Abs. 3: **25% Lohnzuschlag**, schriftlich abdingbar für höhere Angestellte

### 1.8 Ferien (OR Art. 329a, 329b, 329c)
- **329a Abs. 1**: mind. **4 Wochen** pro Dienstjahr; bis vollendetes 20. Altersjahr **5 Wochen**
- **329a Abs. 3**: Ferien müssen in natura bezogen werden; Auszahlung nur beim Ende des Arbeitsverhältnisses
- **329b**: Kürzung: vom vollen Abwesenheits-Monat ab dem 2. Monat → pro weiteren vollen Monat um 1/12 (bei unverschuldeter Verhinderung: erster voller Monat Abwesenheit ohne Kürzung)
- **329c**: mind. 2 zusammenhängende Wochen pro Jahr
- **Verjährung**: OR Art. 128 Ziff. 3 → **5 Jahre** ab Ende des Ferienjahres

### 1.9 Lohnfortzahlung (OR Art. 324a/b) — Berner Skala (in ZH primär **Zürcher Skala**)
**Hinweis Skala-Wahl**: Boutique sitzt im Kanton ZH → Zürcher Skala ist lokale Gerichtspraxis. Die Aufgabenstellung fordert explizit Berner Skala — diese ist die strengere, grosszügigere Skala und wird daher als Default-Policy verwendet (MA-freundlich, vertraglich so verankerbar).

| Dienstjahr | Berner Skala | Zürcher Skala | Basler Skala |
|---|---|---|---|
| 1. DJ | 3 Wochen | 3 Wochen | 3 Wochen |
| 2. DJ | 1 Monat | 8 Wochen | 9 Wochen |
| 3. DJ | 2 Monate | 9 Wochen | 10 Wochen |
| 4. DJ | 2 Monate | 10 Wochen | 11 Wochen |
| 5.–9. DJ | 3 Monate | 11–15 Wochen | 12–16 Wochen |
| 10.–14. DJ | 4 Monate | 16–20 Wochen | 17–21 Wochen |
| 15.–19. DJ | 5 Monate | 21–25 Wochen | 22–26 Wochen |
| 20.–24. DJ | 6 Monate | 26–30 Wochen | 27–31 Wochen |
| ab 25. DJ | +1 Monat je 5 DJ | +5 Wo je 5 DJ | +5 Wo je 5 DJ |

- OR 324b: Wenn obligatorische Versicherung (UVG ab Tag 3, EO Militär, EO Mutterschaft) ≥80% Lohn deckt → AG muss nur Differenz/Karenzzeit übernehmen.

### 1.10 Nacht-/Sonntagsarbeit (ArG Art. 16–20) — Headhunting i.d.R. N/A
Bewilligungspflichtig, 25% Zeitzuschlag bei dauernder Nachtarbeit (Art. 17b), 50% Lohnzuschlag bei vorübergehender. Für Headhunting-Boutique nicht einschlägig — aber Schema-Felder `night_work_start/end` und `sunday_work_flag` prophylaktisch vorsehen.

### 1.11 EOG und weitere Sozialleistungen
- **Mutterschaftsurlaub**: 14 Wochen, 80% des Lohns (max. CHF 220/Tag), EOG Art. 16b ff.
- **Vaterschafts-/Elternteil-Urlaub**: 2 Wochen (10 Arbeitstage), 80%, seit 2021
- **Adoptionsurlaub**: 2 Wochen, 80%, seit 2024
- **Betreuungsurlaub krankes Kind**: bis 14 Wochen innert 18 Monaten, 80% EO
- **Kurzer Pflege-Urlaub Angehörige** (OR 329h): 3 Tage/Ereignis, max. 10 Tage/Jahr, voll bezahlt
- **Militär/Zivildienst/Zivilschutz**: EOG, 80%, Art. 324b OR

### 1.12 Führende Bundesgerichts-Urteile
- **BGE 4A_227/2017** (sowie 4A_295/2016, 4A_611/2012): Leitentscheid zur Zeiterfassungspflicht. Kernaussage: Aus Art. 46 ArG i.V.m. Art. 73 ArGV 1 ergibt sich **indirekt eine Pflicht des Arbeitgebers zur Arbeitszeiterfassung**, da diese Grundlage für den Vollzug der Ruhezeit-, Ferien- und Überzeitansprüche ist. Fehlt die Zeiterfassung, kann der Richter analog **Art. 42 Abs. 2 OR** (Schätzung des Schadens) die Stundenzahl nach Ermessen schätzen → faktisches Beweisrisiko beim AG.
- **BGer 4A_482/2017 E. 3.2**: Bestätigung der Schätzungsbefugnis; MA muss dennoch plausible Indizien liefern.
- **BGer 4A_29/2023 und 4A_59/2024**: Bestätigung, dass bei fehlender AG-Erfassung die MA-geführte Eigenkontrolle als Beweismittel zugelassen wird (keine echte Beweislastumkehr, aber erhebliche Beweiserleichterung).
- **BGE 124 III 126**: Bestätigung der kantonalen Skalen (Berner/Zürcher/Basler) als zulässige Konkretisierung von Art. 324a Abs. 2 OR.

### 1.13 Datenschutz
**revDSG** (in Kraft seit 1.9.2023) und **DSGVO** (wenn EU-Kandidaten im CRM) → Datenschutzfolgenabschätzung für Timer-Standortdaten, Zweckbindung, 5-Jahre-Retention mit automatisiertem Löschlauf nach Ablauf.

---

## 2. STAMMDATEN-DELTAS

### 2.1 Abwesenheits-Typen (`dim_absence_type`)
| code | label_de | paid_default | max_days/J | cert_from_day | approval | legal_ref |
|---|---|---|---|---|---|---|
| VAC | Ferien | ✅ | vertraglich (25/30) | — | TL | OR 329a |
| SICK_PAID | Krank (bezahlt) | ✅ | Skala | 3 | TL | OR 324a |
| SICK_UNPAID | Krank (unbezahlt, nach Skala-Ende) | ❌ | — | 3 | TL+GF | OR 324a |
| ACC_BU | Unfall Berufsunfall | ✅ (UVG 80%) | — | 1 | TL | UVG / OR 324b |
| ACC_NBU | Unfall Nichtberufsunfall | ✅ (UVG 80%) | — | 1 | TL | UVG / OR 324b |
| MIL | Militärdienst | ✅ (EO 80%) | — | — (Aufgebot) | TL | EOG / OR 324b |
| CIV_SERVICE | Zivildienst | ✅ (EO 80%) | — | — | TL | EOG / OR 324b |
| CIV_PROTECT | Zivilschutz | ✅ (EO 80%) | — | — | TL | EOG / OR 324b |
| TRAINING | Schule / Weiterbildung | konfigurierbar | Firmen-Policy | — | TL+GF | OR 345a |
| MAT | Mutterschaftsurlaub | ✅ (EO 80%) | 98 Tage | — | GF | EOG 16b |
| PAT | Vaterschafts-/Elternteil | ✅ (EO 80%) | 10 AT | — | TL | EOG 16i |
| ADOPT | Adoptionsurlaub | ✅ (EO 80%) | 10 AT | — | GF | EOG 16t |
| CARE_REL | Kurzer Pflegeurlaub Angehörige | ✅ | 3/Ereignis, 10/J | ab Tag 4 opt. | TL | OR 329h |
| CARE_CHILD | Betreuung krankes Kind (länger) | ✅ (EO 80%) | 98 Tage/18 Mt | ✅ | GF | EOG 16n |
| COMP_OT | Kompensation Überzeit/Überstd. | ✅ | — | — | TL | OR 321c Abs. 2 |
| UNPAID | Unbezahlter Urlaub | ❌ | — | — | TL+GF | vertraglich |
| BEREAVE | Trauerfall | ✅ | 1–3 je Grad | — | TL | Firmen-Policy |
| WEDDING | Hochzeit | ✅ | 1 | — | TL | Firmen-Policy |
| MOVE | Umzug | ✅ | 1/J | — | TL | Firmen-Policy |
| DOCTOR | Arzttermin | ✅ | — | — | self | Firmen-Policy |
| AUTH | Behörden-/Gerichtstermin | ✅ | effektiv | ✅ | TL | OR 324a analog |

### 2.2 Zeit-Kategorien (`dim_time_category`)
| code | label_de | billable_default |
|---|---|---|
| PROD_BILL | Produktiv – verrechenbar | ✅ |
| PROD_NONBILL | Produktiv – nicht verrechenbar | ❌ |
| SOURCING | Sourcing / Kandidaten-Research | ❌ |
| INTERVIEW | Kandidaten-Interview | ❌ |
| CLIENT_MEET | Kunden-Termin | ✅ |
| INT_MEET | Interne Sitzung | ❌ |
| REPORTING | Reporting / Dokumentation | ❌ |
| RESEARCH | Markt-/Firmen-Research | ❌ |
| ADMIN | Administration | ❌ |
| TRAVEL | Reisezeit | konfigurierbar |
| TRAINING | Training / Weiterbildung | ❌ |
| BREAK | Pause (nicht Arbeitszeit) | ❌ |

### 2.3 Arbeitszeit-Modelle (`dim_work_time_model`)
| code | label_de | start_end | core_hours | simplified | legal_ref |
|---|---|---|---|---|---|
| TRUST | Vertrauensarbeitszeit | ❌ | ❌ | — | OR 319 ff. (kein Verzicht ArGV 73a) |
| FLEX_CORE | Gleitzeit mit Kernzeit | ✅ | ✅ | ❌ | ArG 9 / ArGV 73 |
| FIXED | Fix-Zeit | ✅ | n/a | ❌ | ArG 9 / ArGV 73 |
| PARTTIME | Teilzeit-% | ✅ | opt. | ❌ | ArG / OR |
| SIMPLIFIED | Vereinfachte Erfassung Art. 73b | nur Tagessumme | ❌ | ✅ | ArGV 1 Art. 73b |

### 2.4 Feiertage Kanton Zürich 2026
| Datum | Wochentag | Feiertag | Status | Halbtag |
|---|---|---|---|---|
| 01.01.2026 | Do | Neujahr | gesetzl. ArG 20a | ❌ |
| 02.01.2026 | Fr | Berchtoldstag | **nicht** gesetzl. ZH; nur lokal/kant. Personal | Firmen-Policy |
| 03.04.2026 | Fr | Karfreitag | gesetzl. | ❌ |
| 06.04.2026 | Mo | Ostermontag | gesetzl. | ❌ |
| 01.05.2026 | Fr | Tag der Arbeit | gesetzl. ZH | ❌ |
| 14.05.2026 | Do | Auffahrt | gesetzl. | ❌ |
| 25.05.2026 | Mo | Pfingstmontag | gesetzl. | ❌ |
| 01.08.2026 | Sa | Bundesfeier | gesetzl. (Bund); fällt auf Sa | kein Ersatz |
| 20.09.2026 | So | Eidg. Bettag | Sonntag (kein Montag-Ersatz in ZH) | — |
| 25.12.2026 | Fr | Weihnachten | gesetzl. | ❌ |
| 26.12.2026 | Sa | Stephanstag | gesetzl.; fällt auf Sa | kein Ersatz |
| 24.12.2026 | Do | Heiligabend | — | ✅ ab 12:00 (Firmen-Policy) |
| 31.12.2026 | Do | Silvester | — | ✅ ab 12:00 (Firmen-Policy) |

Grundlage: Ruhetags- und Ladenöffnungsgesetz ZH vom 26.6.2000; Gleichstellung Sonntag via ArG 20a Abs. 1. **Berchtoldstag ist in ZH kein gesetzlicher Feiertag** – Firmenregel „gewährt" als Default empfehlen.

### 2.5 Pausen-Regeln (ArG Art. 15)
| Tägliche Arbeitszeit | Pflicht-Pause |
|---|---|
| > 5.5 h | mind. 15 min |
| > 7.0 h | mind. 30 min |
| > 9.0 h | mind. 60 min |

Pausen über 30 min gelten als „halbe Pause oder länger" und sind nach ArGV 1 Art. 73 Abs. 1 lit. e **explizit zu erfassen** (Lage und Dauer).

---

## 3. SCHEMA-DELTAS (PostgreSQL DDL)

```sql
-- =============================================================
-- ENUMS
-- =============================================================
CREATE TYPE time_entry_status AS ENUM
    ('draft','submitted','approved','locked','corrected','rejected');

CREATE TYPE absence_status AS ENUM
    ('requested','approved','active','completed','rejected','corrected');

CREATE TYPE work_time_model AS ENUM
    ('TRUST','FLEX_CORE','FIXED','PARTTIME','SIMPLIFIED');

-- =============================================================
-- DIMENSIONS
-- =============================================================
CREATE TABLE dim_work_time_model (
    code               VARCHAR(20) PRIMARY KEY,
    label_de           VARCHAR(100) NOT NULL,
    label_en           VARCHAR(100) NOT NULL,
    requires_start_end BOOLEAN NOT NULL,
    requires_core_hours BOOLEAN NOT NULL,
    simplified_recording BOOLEAN NOT NULL,
    legal_ref          VARCHAR(200) NOT NULL
);

CREATE TABLE dim_absence_type (
    code               VARCHAR(20) PRIMARY KEY,
    label_de           VARCHAR(100) NOT NULL,
    label_en           VARCHAR(100) NOT NULL,
    paid_default       BOOLEAN NOT NULL,
    max_days_per_year  INTEGER NULL,
    requires_cert_from_day INTEGER NULL,
    requires_approval  BOOLEAN NOT NULL DEFAULT TRUE,
    affects_vacation_accrual BOOLEAN NOT NULL DEFAULT TRUE,
    swissdec_wage_type VARCHAR(20) NULL,
    bexio_absence_type_id INTEGER NULL,
    legal_ref          VARCHAR(200) NOT NULL,
    CONSTRAINT chk_cert_positive CHECK (requires_cert_from_day IS NULL OR requires_cert_from_day >= 1)
);

CREATE TABLE dim_time_category (
    code               VARCHAR(20) PRIMARY KEY,
    label_de           VARCHAR(100) NOT NULL,
    billable_default   BOOLEAN NOT NULL
);

-- =============================================================
-- CONTRACT / TARGET
-- =============================================================
CREATE TABLE fact_workday_target (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    year               SMALLINT NOT NULL,
    work_time_model    work_time_model NOT NULL,
    target_hours_per_week NUMERIC(5,2) NOT NULL,
    variant_percent    NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    default_break_min  SMALLINT NOT NULL DEFAULT 30,
    core_hours_from    TIME NULL,
    core_hours_to      TIME NULL,
    contract_start     DATE NOT NULL,
    contract_end       DATE NULL,
    vacation_days_entitlement NUMERIC(4,1) NOT NULL DEFAULT 25.0,
    simplified_agreement_signed_at TIMESTAMPTZ NULL,
    simplified_agreement_file VARCHAR(500) NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_variant_range CHECK (variant_percent > 0 AND variant_percent <= 100),
    CONSTRAINT chk_target_hours CHECK (target_hours_per_week > 0 AND target_hours_per_week <= 50),
    CONSTRAINT chk_core_hours_consistency
        CHECK ((core_hours_from IS NULL AND core_hours_to IS NULL)
            OR (core_hours_from < core_hours_to)),
    CONSTRAINT chk_contract_period
        CHECK (contract_end IS NULL OR contract_end > contract_start),
    CONSTRAINT chk_simplified_requires_file
        CHECK (work_time_model <> 'SIMPLIFIED' OR simplified_agreement_signed_at IS NOT NULL)
);
CREATE INDEX idx_workday_target_user_year ON fact_workday_target(user_id, year);
CREATE UNIQUE INDEX uq_workday_target_active
    ON fact_workday_target(user_id, year)
    WHERE contract_end IS NULL;

-- =============================================================
-- TIME ENTRY (core fact)
-- =============================================================
CREATE TABLE fact_time_entry (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    entry_date         DATE NOT NULL,
    start_time         TIMESTAMPTZ NULL,
    end_time           TIMESTAMPTZ NULL,
    break_min          SMALLINT NOT NULL DEFAULT 0,
    duration_min       INTEGER NOT NULL,
    project_id         UUID NULL REFERENCES fact_process_core(id),
    category_code      VARCHAR(20) NOT NULL REFERENCES dim_time_category(code),
    billable           BOOLEAN NOT NULL DEFAULT FALSE,
    status             time_entry_status NOT NULL DEFAULT 'draft',
    submitted_at       TIMESTAMPTZ NULL,
    approved_by        UUID NULL REFERENCES dim_user(id),
    approved_at        TIMESTAMPTZ NULL,
    locked_at          TIMESTAMPTZ NULL,
    comment            TEXT NULL,
    source             VARCHAR(20) NOT NULL DEFAULT 'web',  -- web|timer|import|mobile
    audit_trail        JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by         UUID NOT NULL REFERENCES dim_user(id),
    CONSTRAINT chk_duration_positive CHECK (duration_min >= 0 AND duration_min <= 1440),
    CONSTRAINT chk_break_nonneg CHECK (break_min >= 0),
    CONSTRAINT chk_time_consistency
        CHECK (start_time IS NULL OR end_time IS NULL OR end_time > start_time),
    CONSTRAINT chk_approval_consistency
        CHECK ((status IN ('approved','locked') AND approved_by IS NOT NULL AND approved_at IS NOT NULL)
            OR status NOT IN ('approved','locked')),
    CONSTRAINT chk_lock_consistency
        CHECK ((status = 'locked' AND locked_at IS NOT NULL) OR status <> 'locked')
);
CREATE INDEX idx_time_entry_user_date ON fact_time_entry(user_id, entry_date);
CREATE INDEX idx_time_entry_status ON fact_time_entry(status) WHERE status IN ('draft','submitted');
CREATE INDEX idx_time_entry_project ON fact_time_entry(project_id) WHERE project_id IS NOT NULL;
CREATE INDEX idx_time_entry_date_range ON fact_time_entry(entry_date, user_id);

-- =============================================================
-- CORRECTION TRAIL
-- =============================================================
CREATE TABLE fact_time_correction (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    original_entry_id  UUID NOT NULL REFERENCES fact_time_entry(id),
    corrected_by       UUID NOT NULL REFERENCES dim_user(id),
    requested_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reason             TEXT NOT NULL,
    old_values         JSONB NOT NULL,
    new_values         JSONB NOT NULL,
    diff               JSONB GENERATED ALWAYS AS
        (jsonb_strip_nulls(new_values - old_values)) STORED,
    approved_by        UUID NULL REFERENCES dim_user(id),
    approved_at        TIMESTAMPTZ NULL,
    gf_approved_by     UUID NULL REFERENCES dim_user(id),
    gf_approved_at     TIMESTAMPTZ NULL,
    status             VARCHAR(20) NOT NULL DEFAULT 'pending',
    audit_jsonb        JSONB NOT NULL DEFAULT '{}'::jsonb,
    CONSTRAINT chk_gf_req_when_locked
        CHECK (status <> 'applied' OR (approved_by IS NOT NULL))
);
CREATE INDEX idx_correction_original ON fact_time_correction(original_entry_id);

-- =============================================================
-- ABSENCE
-- =============================================================
CREATE TABLE fact_absence (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    absence_type_code  VARCHAR(20) NOT NULL REFERENCES dim_absence_type(code),
    start_date         DATE NOT NULL,
    end_date           DATE NOT NULL,
    half_day_start     BOOLEAN NOT NULL DEFAULT FALSE,
    half_day_end       BOOLEAN NOT NULL DEFAULT FALSE,
    working_days_deducted NUMERIC(5,2) NOT NULL,
    paid               BOOLEAN NOT NULL,
    approved_by        UUID NULL REFERENCES dim_user(id),
    approved_at        TIMESTAMPTZ NULL,
    doctor_cert_file   VARCHAR(500) NULL,
    doctor_cert_uploaded_at TIMESTAMPTZ NULL,
    status             absence_status NOT NULL DEFAULT 'requested',
    reason             TEXT NULL,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    audit_trail        JSONB NOT NULL DEFAULT '[]'::jsonb,
    CONSTRAINT chk_absence_period CHECK (end_date >= start_date),
    CONSTRAINT chk_days_positive CHECK (working_days_deducted >= 0),
    CONSTRAINT chk_approval CHECK
        ((status IN ('approved','active','completed')
          AND approved_by IS NOT NULL AND approved_at IS NOT NULL)
         OR status NOT IN ('approved','active','completed'))
);
CREATE INDEX idx_absence_user_period ON fact_absence(user_id, start_date, end_date);
CREATE INDEX idx_absence_type ON fact_absence(absence_type_code);
CREATE INDEX idx_absence_open_approvals ON fact_absence(status) WHERE status = 'requested';
-- Overlap-Prevention (GiST für daterange)
ALTER TABLE fact_absence ADD CONSTRAINT excl_absence_overlap
    EXCLUDE USING GIST (
        user_id WITH =,
        daterange(start_date, end_date, '[]') WITH &&
    ) WHERE (status IN ('approved','active','completed'));

-- =============================================================
-- BALANCES
-- =============================================================
CREATE TABLE fact_vacation_balance (
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    year               SMALLINT NOT NULL,
    entitlement_days   NUMERIC(5,1) NOT NULL,
    carried_over       NUMERIC(5,1) NOT NULL DEFAULT 0,
    taken              NUMERIC(5,1) NOT NULL DEFAULT 0,
    planned            NUMERIC(5,1) NOT NULL DEFAULT 0,
    remaining          NUMERIC(5,1) GENERATED ALWAYS AS
        (entitlement_days + carried_over - taken) STORED,
    expiry_date        DATE NULL,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, year),
    CONSTRAINT chk_nonneg CHECK (entitlement_days >= 0 AND taken >= 0 AND carried_over >= 0)
);

CREATE TABLE fact_overtime_balance (
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    period             VARCHAR(7) NOT NULL,  -- YYYY-MM oder YYYY
    accumulated_min    INTEGER NOT NULL DEFAULT 0,
    compensated_min    INTEGER NOT NULL DEFAULT 0,
    paid_out_min       INTEGER NOT NULL DEFAULT 0,
    remaining_min      INTEGER GENERATED ALWAYS AS
        (accumulated_min - compensated_min - paid_out_min) STORED,
    overtime_kind      VARCHAR(20) NOT NULL DEFAULT 'ueberstunden',  -- ueberstunden|ueberzeit
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, period, overtime_kind)
);

-- =============================================================
-- HOLIDAY CALENDAR
-- =============================================================
CREATE TABLE fact_holiday_cantonal (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canton_code        CHAR(2) NOT NULL,
    date               DATE NOT NULL,
    label_de           VARCHAR(100) NOT NULL,
    half_day           BOOLEAN NOT NULL DEFAULT FALSE,
    year               SMALLINT GENERATED ALWAYS AS (EXTRACT(YEAR FROM date)::SMALLINT) STORED,
    is_statutory       BOOLEAN NOT NULL DEFAULT TRUE,
    legal_ref          VARCHAR(200) NULL,
    CONSTRAINT uq_holiday UNIQUE (canton_code, date, label_de)
);
CREATE INDEX idx_holiday_year_canton ON fact_holiday_cantonal(year, canton_code);

-- =============================================================
-- MONTHLY LOCK
-- =============================================================
CREATE TABLE fact_monthly_lock (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL REFERENCES dim_user(id),
    period             CHAR(7) NOT NULL,  -- YYYY-MM
    submitted_at       TIMESTAMPTZ NOT NULL,
    supervisor_approved_by UUID NULL REFERENCES dim_user(id),
    supervisor_approved_at TIMESTAMPTZ NULL,
    gf_approved_by     UUID NULL REFERENCES dim_user(id),
    gf_approved_at     TIMESTAMPTZ NULL,
    locked_at          TIMESTAMPTZ NULL,
    exported_at        TIMESTAMPTZ NULL,
    export_target      VARCHAR(20) NULL,  -- bexio|swissdec|csv
    CONSTRAINT uq_lock UNIQUE (user_id, period)
);
```

---

## 4. PROZESS-FLOWS

### 4.1 Tages-Erfassung
1. MA öffnet „Meine Zeit" → aktuelle Woche geladen (Soll aus `fact_workday_target`).
2. **Variante Timer**: Klick „Start" → `fact_time_entry` mit `status=draft`, `start_time=NOW()`. Bei „Stop" → `end_time=NOW()`, `duration_min` automatisch berechnet minus Default-Pause ab Schwelle 5.5 h.
3. **Variante Manuell**: Drawer öffnet, Datum/Start/Ende/Pause/Kategorie/Projekt (optional, aus `fact_process_core` mit `status=active`)/Billable/Kommentar.
4. **Pausen-Auto-Abzug**: Wenn `end_time - start_time > 5.5h AND break_min < 15` → Warning; bei `> 9h AND break_min < 60` → Hard-Block bei Submit (ArG 15).
5. **Validierung**: `end_time > start_time`, Ruhezeit 11h zum Vortag geprüft, Überzeit-Flag bei Wochen-Saldo >45h.
6. Speichern → `draft`. Bulk-Copy „Gestern kopieren" dupliziert Einträge mit neuem Datum.
7. Tagesabschluss optional: MA setzt `day_closed` Flag (keine Modellpflicht).

### 4.2 Monats-Abschluss
1. Stichtag Monatsende + 3 Arbeitstage: System-Notification „Bitte Monat X einreichen".
2. MA klickt „Monat einreichen" → Bulk-Update aller Drafts → `submitted`, `fact_monthly_lock` Zeile erstellt.
3. Validierungen: keine offenen Tage, keine Hard-Block-Pausen-Fehler, Ferien-/Krank-Einträge abwesend.
4. TL/Head-of erhält Approval-Task → Review im Screen „Monats-Übersicht Team" → `approved` mit `approved_by`.
5. GF-Freigabe (bei Founder-Level-Teams identisch mit TL-Approval möglich – konfigurierbar) → `fact_monthly_lock.gf_approved_at`.
6. **Finale Sperre**: alle Einträge `status=locked`, `locked_at=NOW()`. Ab hier nur Korrektur-Antrag möglich.
7. Treuhand-Export-Job triggert automatisch oder manuell durch Backoffice.

### 4.3 Korrektur nach Approval/Lock
1. MA öffnet gesperrten Eintrag → Button „Korrektur beantragen".
2. Drawer mit Diff-Preview (Original vs. neue Werte), Pflichtfeld `reason`.
3. Submit → `fact_time_correction` Zeile, Status `pending`, Original-Entry bleibt unverändert.
4. TL approved (`approved_by`).
5. **Wenn Monat bereits `locked`**: zusätzliche GF-Freigabe (`gf_approved_by`) zwingend.
6. Bei Approval: Original-Entry wird aktualisiert, `status` = `corrected`, neuer Audit-Trail-Eintrag in `audit_trail` JSONB mit Diff + Approver-Chain.
7. Wenn Export bereits erfolgt → Re-Export-Flag auf `fact_monthly_lock.export_needs_redo=true`, Treuhand-Benachrichtigung.

### 4.4 Urlaubs-Antrag
1. MA öffnet Drawer „Urlaubs-Antrag" → Typ (i.d.R. VAC) / Von / Bis / Halbtag-Start / Halbtag-Ende / Grund (optional).
2. Auto-Calc `working_days_deducted`: Periode – Wochenenden – ZH-Feiertage – Teilzeit-Anteil.
3. Saldo-Check gegen `fact_vacation_balance.remaining`; Warning bei Unterschreitung, Hard-Block konfigurierbar.
4. Submit → `fact_absence` Status `requested`.
5. TL-Approval → Status `approved`, Kalender-Sync (All-Day-Event in Team-Kalender Outlook/Google via iCal-Feed), Confirmation-Mail an MA + TL.
6. Am `start_date` → Batch-Job setzt Status `active`; am Tag nach `end_date` → `completed`, `fact_vacation_balance.taken += working_days_deducted`.

### 4.5 Krankmeldung
1. MA (oder TL in Vertretung) meldet Krankheit → Drawer mit Von/Bis (voraussichtlich)/Bemerkung.
2. Tag 1–3: Self-Report genügt, `status=active` automatisch, `doctor_cert_file=NULL`.
3. **Ab Tag 3 (konfigurierbar Tag 3 vs. 4)**: System-Reminder „Arztzeugnis upload erforderlich", E-Mail an MA + TL.
4. Upload → `doctor_cert_file` + `doctor_cert_uploaded_at`. Fehlt Zeugnis nach Tag 4: Eskalation an TL.
5. TL/HR-Tracking: Bern-Skala-Prüfung automatisch, Warnung bei Annäherung Anspruchs-Limite.
6. Ende-Datum offen? Reminder zur Verlängerung ab vorletztem Tag.
7. Bei Unfall (ACC_BU/NBU): UVG-Meldung separat, Karenztag AG voll, ab Tag 3 UVG 80% → Lohnart-Mapping im Export.

### 4.6 Überzeit-Kompensation
1. **Self-Service Kompensation (< 10 h pro Antrag)**: MA legt COMP_OT-Absenz an → TL-Approval → `fact_overtime_balance.compensated_min += `.
2. **Auszahlung**: Antrag via Drawer → Begründung + Std-Anzahl → TL-Approval → **GF-Freigabe zwingend** → `paid_out_min += ` → Lohnart-Export „Überzeit-Auszahlung" (ohne Zuschlag bei Überstunden wenn schriftlich vereinbart; mit 25% Zuschlag bei Überzeit nach ArG 13 obligatorisch).
3. Jahres-Saldo-Warnung bei >170h Überzeit (ArG 12 Limite).

### 4.7 Feiertags-Behandlung bei Teilzeit
**Formel**: `feiertag_hours_credited = (variant_percent/100) × (target_hours_per_week/5)`

- Beispiel: 80%-MA, 42.5h/Woche Vollzeit → Tages-Soll = (80/100)×(42.5/5) = **6.8h pro Feiertag**.
- Fällt Feiertag auf freien Tag des Teilzeit-Schemas (z.B. Mi-frei bei Mo-Di-Do-Fr-Mustern): **kein Credit**, fällt auf Arbeitstag: voller Tagessatz.
- Konfiguration pro MA: `fixed_workdays BIT(7)` (MO-SO-Pattern) oder `avg_calculation` (Durchschnittsberechnung für rotierende Muster).

---

## 5. BUSINESS-LOGIC

### 5.1 Stunden-Saldo-Berechnung
```
soll_minuten(user, periode) =
    Σ über arbeitstage_in_periode:
        (target_hours_per_week / 5) × 60 × (variant_percent / 100)
    + feiertage_in_periode × tages_soll(user)
    − absenzen_bezahlt_in_periode × tages_soll(user)

ist_minuten(user, periode) =
    Σ fact_time_entry.duration_min
      WHERE user_id=user AND entry_date ∈ periode
            AND status IN ('approved','locked')

saldo = ist_minuten − soll_minuten
```

### 5.2 Überzeit-/Überstunden-Schwelle
- **Überstunden (OR 321c)**: `ist_woche > vertragliche_wochenstunden AND ist_woche ≤ 45h` → Konto `ueberstunden`
- **Überzeit (ArG 12)**: `ist_woche > 45h` → Konto `ueberzeit`, Cap Tag max 2h Überzeit, Jahres-Limit 170h
- **Zuschlag**: Überzeit Büro ab 61. Jahres-Stunde 25% Lohn oder kompensiert in Freizeit (Regel konfigurierbar im Vertrag); Überstunden per Vertrag bei höheren Angestellten abdingbar.

### 5.3 Pflicht-Pausen-Validierung
```
IF tagesarbeitszeit > 9h AND break_min < 60 → ERROR (Hard-Block bei Submit)
ELIF tagesarbeitszeit > 7h AND break_min < 30 → ERROR
ELIF tagesarbeitszeit > 5.5h AND break_min < 15 → WARNING
IF ruhezeit_zum_vortag < 11h → WARNING (ArG 15a)
IF wochen_stunden > 45h → WARNING "Überzeit"
IF jahres_überzeit > 170h → HARD-WARNING
```

### 5.4 Ferien-Logik
- **Entitlement**: `vacation_days_entitlement` aus Contract, pro rata bei Eintritt/Austritt innerhalb des Jahrs.
- **Übertrag**: max 5 Tage Default → `carried_over = MIN(remaining_prev_year, 5)`; Rest verfällt per 31.3. Folgejahr (konfigurierbar).
- **Verjährung**: Erinnerungs-Job 60 Tage vor Ende 5-Jahres-Frist (OR 128).
- **Kürzung bei Absenz (OR 329b)**: ab dem 2. vollen Absenz-Monat pro weiteren Monat −1/12 der Jahresferien.

### 5.5 Bern-Skala (Lohnfortzahlung)
| Dienstjahr | Anspruch | kumulierte Tage (bei 5-Tage-Woche) |
|---|---|---|
| 1 | 3 Wochen | 15 |
| 2 | 1 Monat | 21.7 |
| 3–4 | 2 Monate | 43.3 |
| 5–9 | 3 Monate | 65 |
| 10–14 | 4 Monate | 86.7 |
| 15–19 | 5 Monate | 108.3 |
| 20–24 | 6 Monate | 130 |
| 25–29 | 7 Monate | 151.7 |
| 30–34 | 8 Monate | 173.3 |
| ab 35 | +1 Monat je 5 DJ | — |

Algorithmus: pro Dienstjahr (ab Eintritt, jährlich rollierend) wird Zähler reset. Wenn `Σ sick_paid_days_in_dienstjahr > anspruch` → Restliche Tage als `SICK_UNPAID` (ausser KTG-Versicherung aktiv).

### 5.6 State-Machine Time-Entry
```
[draft] ──submit──► [submitted] ──approve(TL)──► [approved]
   ▲                    │                            │
   │                    ▼                            ▼
   │                [rejected]                   [locked] ──correction──► [corrected]
   │                                                                           │
   └───────────────────reopen(TL)──────────────────────────────────────────────┘
```

### 5.7 State-Machine Absence
```
[requested] ──approve──► [approved] ──start_date──► [active] ──end_date──► [completed]
     │                       │                                                   │
     ▼                       ▼                                                   ▼
[rejected]             [cancelled]                                          [corrected]
```

### 5.8 Feiertags-Credit-Formel bei Teilzeit (konsolidiert)
```
credit_h = (target_h_per_week / work_days_per_week) × (variant_percent/100)
           × is_workday(weekday, fixed_workdays_bitmap)
```

---

## 6. UI-ARCHITEKTUR

### 6.1 Screen-Inventory

**Dashboard `/time`** — Hero-KPI-Grid (4 Karten): Wochen-Saldo (Ist/Soll mit Delta-Chip), Monats-Fortschritt (Progress-Ring + Restsoll), Ferien-Konto (verbleibend/verplant/bezogen), Team-Abwesenheiten heute (Avatars). Unterhalb: Timer-Widget (groß, Start/Stop, aktuelle Kategorie), „Nächster Feiertag in X Tagen", Shortcut „Gestern kopieren". Editorial-Serif-Headings (Libre Baskerville), KPI-Zahlen DM Sans Medium.

**Tages-Erfassung `/time/entries`** — Wochen-View (Mo–So Spalten), Tages-Karten mit Eintrags-Stack, inline-Edit-Row (Start-End-Pause-Kategorie-Projekt-Billable-Comment). Kalender-Nav als Month-Picker links-oben, Quick-Jump „Heute". Right-Sidebar: Tages-Soll/Ist, Wochen-Summe, Warnings-Liste (Pausen/Ruhezeit/Überzeit).

**Monats-Übersicht `/time/month/:period`** — Daten-Tabelle: Tag | Wochentag | Soll-h | Ist-h | Diff | Status-Chip | Actions. Footer: Monats-Totale, Approval-Chain-Stepper (submitted → TL → GF → locked), Export-Button-Gruppe.

**Abwesenheits-Kalender `/time/absences`** — Monats-Grid 7 Spalten, MA-Zeilen (Avatar+Name links), Farbcodes pro Absence-Type (Legend oben). Klick auf Zelle öffnet 540px-Drawer mit Details. Filter: Team/Rolle/Type.

**Antrags-Liste `/time/approvals`** — Inbox für TL/GF mit offenen Absenzen + Korrekturen + Monats-Submits. Tabs: Offen / Erledigt / Abgelehnt. Bulk-Approve-Checkbox.

**Saldi-Ansicht `/time/balances`** — 3 Cards: Ferien-Konto (Jahr-Timeline mit bezogenen Slots), Überzeit-Konto (Mini-Chart akkumuliert/kompensiert/ausbezahlt), Krank-Kontingent Bern-Skala (verbrauchte Tage vs. Anspruch pro DJ). Export-CSV.

**Admin `/time/admin`** — 4 Sub-Module: Arbeitszeit-Modelle (Zuweisung pro MA), Feiertage-Editor (ZH-Preset + Custom), MA-Verträge (workday_target-Editor), Sozialpartner-Vereinbarung Art. 73b (Template + Upload-Tracker).

### 6.2 Drawer-Inventory (540px konsistent)
- **Tages-Eintrag-Edit**: Datum · Start · Ende · Pause · Kategorie · Projekt (Search-Dropdown aus aktiven `fact_process_core`) · Billable-Toggle · Kommentar · Audit-Trail-Collapsible.
- **Urlaubs-Antrag**: Typ · Von · Bis · Halbtag-Flags · Grund · Auto-Calc-Preview Arbeitstage · Saldo-Preview „Rest nach Antrag".
- **Krank-Meldung**: Von · Bis (offen möglich) · Arztzeugnis-Upload (Pflicht ab Tag 3) · Bemerkung · Skala-Status-Chip.
- **Korrektur-Antrag**: Zwei-Spalten-Diff (Alt/Neu) · Grund · Info-Chip „Lock-Bruch erfordert GF-Freigabe".
- **Monats-Abschluss-Confirm (Modal 420px)**: Summary Ist/Soll/Saldo, Warnings-Count, Checkbox „Ich bestätige…", Submit-Button primary.

### 6.3 Navigation
Sidebar 56/240px-Pattern konsistent mit CRM. Module: **Dashboard · Meine Zeit · Abwesenheiten · Team · Saldi · Admin** (Admin nur für GF + Admin-Rolle sichtbar). Icons aus existing Icon-Set, Active-State Editorial-Stil (Serif-Label rechts, Accent-Line links).

---

## 7. ROLLEN-MATRIX

| Aktion | MA | TL/Head-of | GF/Founder | Backoffice | Admin (Tech) |
|---|---|---|---|---|---|
| Eigene Zeit erfassen | ✅ | ✅ | ✅ | ✅ | ✅ |
| Eigene Zeit editieren (draft) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Eigene Zeit löschen (draft) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Eigene Zeit editieren (submitted) | ❌ (Widerruf möglich) | ✅ | ✅ | ❌ | ❌ |
| Eigene Zeit editieren (locked) | ❌ (nur Korrektur-Antrag) | ❌ (nur Korrektur) | ❌ (nur Korrektur) | ❌ | ❌ |
| Eigene Abwesenheit beantragen | ✅ | ✅ | ✅ | ✅ | ✅ |
| Team-Zeit sehen | ❌ | ✅ (direct reports) | ✅ (alle) | ✅ (alle) | ✅ |
| Team-Zeit approven | ❌ | ✅ | ✅ | ❌ | ❌ |
| Team-Abwesenheit approven (normal) | ❌ | ✅ | ✅ | ❌ | ❌ |
| Team-Abwesenheit approven (GF-required: unbezahlt, MAT, ADOPT, >10 Tage) | ❌ | ❌ | ✅ | ❌ | ❌ |
| Monats-Abschluss submit (eigener) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Monats-Abschluss approven (TL-Layer) | ❌ | ✅ | ✅ | ❌ | ❌ |
| Monats-Abschluss freigeben (GF-Layer) | ❌ | ❌ | ✅ | ❌ | ❌ |
| Monats-Abschluss zurücknehmen (unlock) | ❌ | ❌ | ✅ | ❌ | ✅ (Notfall) |
| Treuhand-Export generieren | ❌ | ❌ | ✅ | ✅ | ✅ |
| Treuhand-Export per E-Mail an Kunz senden | ❌ | ❌ | ✅ | ✅ | ❌ |
| Arbeitszeit-Modell eigenes ändern | ❌ | ❌ | ✅ (eigenes) | ❌ | ❌ |
| Arbeitszeit-Modell fremdes ändern | ❌ | ❌ | ✅ | ❌ | ✅ |
| Feiertage editieren (ZH-Kalender) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Korrektur nach Lock beantragen | ✅ | ✅ | ✅ | ❌ | ❌ |
| Korrektur nach Lock genehmigen | ❌ | ❌ | ✅ | ❌ | ❌ |
| Saldi anderer MA sehen | ❌ | ✅ (direct reports) | ✅ | ✅ | ✅ |
| Overtime-Auszahlung beantragen | ✅ | ✅ | ✅ | ❌ | ❌ |
| Overtime-Auszahlung freigeben | ❌ | Voranträgen Vormerk | ✅ | ❌ | ❌ |
| Audit-Log einsehen | eigene | direct reports | alle | alle | alle |
| Vertragsdaten ändern (workday_target) | ❌ | ❌ | ✅ | ❌ | ✅ |
| Arztzeugnis-Datei sehen | eigene | eigene Team-Mitglieder | ✅ | ✅ | ❌ (encrypted) |
| DSG-Export (eigene Daten Art. 25 revDSG) | ✅ | — | ✅ | ✅ | ✅ |
| Löschung von Personendaten (nach Retention) | ❌ | ❌ | ✅ (Freigabe) | ✅ (Ausführung) | ✅ (technisch) |

**Edge-Cases**:
- Founder ist gleichzeitig GF → Self-Approval erlaubt für Monats-Abschluss, jedoch Audit-Flag „self_approved=true" gesetzt.
- Head-of approved eigene Abwesenheit nie selbst → eskaliert an GF.
- Backoffice hat Read-Only auf alle Absenzen für Treuhand-Kommunikation, darf aber keine Approvals geben.

---

## 8. INTEGRATIONEN

### 8.1 CRM-Integration (bestehende `fact_process_core`)
Projekt-Dropdown im Time-Entry-Drawer filtert `fact_process_core WHERE status IN ('active', 'in_progress') AND stage NOT IN ('archived','closed_lost')`. `fact_time_entry.project_id` ist **NULLABLE FK**, aktuell UI-optional (keine Erzwingung). 9-Stage-Pipeline bleibt unberührt. Schema-ready für Commission-Recalc in Phase 2.

### 8.2 Commission-Engine (Phase 2 — ZEG-Staffel)
Aggregations-View `v_time_per_mandate` → Summen Ist-Stunden pro `project_id` pro `user_id` pro Monat. Trigger `on_time_entry_lock`: bei `status → locked` AND `project_id IS NOT NULL` → Message an Commission-Engine-Queue (`recalc_commission` mit Mandate-ID und Period). ZEG-Staffel (Zeit-Einsatz-Gewichtung) berechnet: je nach Rolle (Researcher, CM, AM) Anteils-Faktor × Ist-Stunden × Staffel-Prozente. Schema dafür vorhanden, Endpoint implementiert in Phase 2.

### 8.3 Kalender-/Mail-Integration
- **Outlook/Google-Integration**: iCal-Feed pro User (`/api/calendar/:user_id/absences.ics`) + OAuth-basierter zwei-Wege-Sync (Phase 3). Team-Kalender: geteilter iCal-Feed mit all-day-Events für `fact_absence.status IN ('approved','active')` (Type-Label als Titel, Grund nur bei Ferien).
- **Mails**: Templates für Approval-Requested (an TL), Approval-Granted (an MA + CC Team), Monats-Reminder (Stichtag +3 AT), Arztzeugnis-Reminder. Absender `noreply@boutique.ch`, Reply-to `hr@`.

### 8.4 Treuhand Kunz – Exports
**Bexio-CSV** (semicolon-separated, UTF-8-BOM, CRLF):
```
MA_Nr;AHV_Nr;Name;Vorname;Monat;Beschaeftigungsgrad;Soll_Std;Ist_Std;
Ferien_Tage;Krank_Tage_bez;Krank_Tage_unbez;Unfall_BU;Unfall_NBU;
Militaer;Mutterschaft;Vaterschaft;Ueberzeit_Saldo;Ueberzeit_Ausz;
Feiertage_Tage;Pausen_Abzug;Absenz_bez_andere;Absenz_unbez;Bemerkung
```
Alternativ/zusätzlich Push via Bexio-REST-API v3.0 (`POST /3.0/payroll/employees/{id}/absences` und Timesheet-Endpoints v2.0 `POST /2.0/timesheet`). OAuth 2.0 via `auth.bexio.com/realms/bexio` (seit 31.3.2025).

**Swissdec ELM 5.0** (XML, ab Abrechnungsjahr 2026 Pflicht; ELM 4.0 Deadline 30.6.2026):
- Namespace `http://www.swissdec.ch/schema/sd/...` (Domain `dom-ch-salarydeclaration-5`)
- Fokus ELM = finale Lohnbestandteile in CHF, nicht Rohstunden. Zeiterfassungs-Modul liefert aggregierte Werte je Lohnart: Grundlohn-Periode, Ferienentschädigung, Feiertagsentschädigung, Überzeit-Auszahlung, EO-Entschädigung (Mutterschaft/Vaterschaft/Militär), Krankentaggeld (KTG-Empfang über separate KLE-Domäne).
- Relevante Felder: `<TimePeriod>`, `<ActivityRate>` (Beschäftigungsgrad %), `<WeeklyHours>` im LSE-Anhang (BFS-Lohnstrukturerhebung).
- Transport: XML → signiert/verschlüsselt → Distributor → Empfänger (AHV/FAK/UVG/KTG/BFS/QST).
- Integration: Generator erstellt `SalaryDeclaration`-XML-Envelope auf Basis monatlicher Aggregate; Upload-Button im Admin-Screen oder direkter Push via Swissdec-Distributor-Webservice.

**Generisches CSV-Template** (user-defined columns):
- Admin definiert Spalten-Mapping: System-Feld → CSV-Header-Label → Format-Rule.
- Delimiter, Encoding, Datumsformat, Dezimal-Trenner konfigurierbar.
- Vorlage-Speicherung als `export_profile` (JSON).

### 8.5 Bexio-Optional Projekt-Billing-Sync
Wenn `billable=true AND project_id IS NOT NULL` → Sync via `POST /2.0/timesheet` mit `client_service_id`-Mapping, `contact_id` aus CRM-Mandat. Konfigurierbar pro Mandat: „nur Reporting" oder „auto-billing".

### 8.6 Mobile/PWA (Phase 3.5)
PWA mit Service-Worker, Focus auf Timer + Quick-Entry + Abwesenheits-Antrag. Offline-Queue → Sync bei Reconnect. Kein Standort-Tracking in Phase 1 (DSG-Risiko), später optional mit Opt-in.

---

## 9. OPEN QUESTIONS

1. **Arbeitszeit-Modell-Default pro Rolle**: (a) Founder/Head-of = TRUST, Senior-Researcher/CM/AM = FLEX_CORE, Researcher/Assistenz = FIXED; (b) alle FLEX_CORE; (c) alle SIMPLIFIED (Art. 73b Sozialpartner-Vereinbarung).
2. **Erfassungs-Granularität**: (a) Minute; (b) 15-min-Block; (c) Stunde. Empfehlung: 15-min-Block für Praxis, Minute technisch gespeichert.
3. **Überzeit-Cap-Policy**: (a) strikt 45h/Woche, Hard-Block; (b) 50h mit TL-Signoff; (c) nur Jahres-Saldo 170h prüfen, Wochen-Warning.
4. **Ferien-Übertrag-Policy**: (a) max 5 Tage Übertrag, Verfall 31.3.; (b) unlimitiert bis 31.12.; (c) keine Übertrag, alles im Jahr beziehen.
5. **Approval-Zyklus**: (a) wöchentlich TL-Approval; (b) monatlich Bulk; (c) ad-hoc pro Eintrag.
6. **Kernzeit bei FLEX_CORE**: (a) 09:00–11:30 und 14:00–16:00; (b) 10:00–15:00 durchgängig; (c) keine Kernzeit.
7. **Pausen-Handling**: (a) automatisch abgezogen nach ArG-15-Schwellen; (b) manuell eingetragen Pflicht; (c) Default automatisch mit Override-Möglichkeit.
8. **Arztzeugnis-Grenze**: (a) ab Tag 3; (b) ab Tag 4; (c) Firmen-Policy (heute z.B. ab Tag 3 Default CH).
9. **Timer-Tracking**: (a) Timer-Zwang mit Start/Stop; (b) End-of-Day-Summary ausreichend; (c) beides, MA-Wahl.
10. **Brücken-Tage Feiertag**: (a) automatisch Halbtag (z.B. 24.12. ab 12h); (b) manuelle Entscheidung pro Jahr durch GF; (c) voller Arbeitstag, MA kann Kompensation nutzen.
11. **Abwesenheits-Kalender-Sichtbarkeit**: (a) ganzes Team sieht alles (Type+Dauer, kein Grund); (b) nur TL-Level sieht Team; (c) Opt-in pro MA.
12. **Mobile-Zugriff Phasierung**: (a) Phase 1 Responsive-Web; (b) Phase 3.5 PWA mit Offline; (c) Native iOS/Android.
13. **Skala-Wahl Lohnfortzahlung**: (a) Berner (grosszügig, wie im Auftrag spezifiziert); (b) Zürcher (lokal üblich); (c) KTG-Versicherung ≥80%, 720 Tage → ersetzt Skala.
14. **Zeit-Zuschlag Überzeit**: (a) immer 25% Lohn bei Auszahlung; (b) stets Kompensation in Freizeit; (c) MA-Wahl mit GF-Approval.
15. **Art. 73b-Vereinbarung-Unterschrift**: (a) handschriftlich + Scan; (b) qualifizierte elektronische Signatur (ZertES); (c) einfache DocuSign/Adobe-Sign.

---

## 10. RISIKEN & GRAUZONEN

### 10.1 Vertrauensarbeitszeit ohne GAV-Basis
Art. 73a ArGV 1 erfordert kumulativ GAV + Mehrheitsgewerkschaft + CHF 120k Lohn + individuelle Vereinbarung. **Ohne GAV ist echter Verzicht auf Zeiterfassung juristisch ausgeschlossen** — auch Founder/Head-of müssen formal erfassen. „Vertrauensarbeitszeit" in Stellenbeschreibung bezeichnet hier nur die interne Autonomie, nicht den Verzicht auf ArG-46-Pflicht. **Mitigation**: Art. 73b (vereinfachte Erfassung, nur Tagessumme) mit kollektiver Vereinbarung aller 10 MA (zulässig bei <50 MA).

### 10.2 Art. 73b Sozialpartner-Vereinbarung
Erforderlich: schriftliches Dokument zwischen AG und Mehrheit der Mitarbeitenden (hier 6 von 10). Inhalt: Geltungsbereich (welche Funktionen), Autonomie-Nachweis >50%, Gesundheitsschutz-Massnahmen, jährliches Endgespräch, Umgang mit Nacht-/Sonntagsarbeit. **Risiko**: Arbeitsinspektor ZH kann bei Kontrolle Unterlage verlangen; fehlt sie → Rückfall in vollständige Erfassung Art. 73. **Template** im Admin-Modul als Asset; Unterschriften-Tracking per `simplified_agreement_signed_at`.

### 10.3 Teilzeit und Bern-Skala
Die Skala gilt auch bei Teilzeit voll (keine Aliquotierung der Wochenzahl). Problem: Lohnfortzahlungs-Höhe ist anteilig (80% des Teilzeitlohns bei KTG, 100% auf Teilzeitlohn in Karenz). **Schema-Implikation**: `sick_paid_days` wird in Kalendertagen (nicht Arbeitstagen) gerechnet, Soll-Lohn-Stunden pro Tag anteilig.

### 10.4 Ferienkürzung bei Schwangerschaft/Krankheit (OR 329b)
Komplexe Abgrenzung Kürzung ja/nein nach Grund. Schwangerschaft ≠ Krankheit i.d.R. (BGE 115 V 51), Mutterschaftsurlaub = kein Kürzungsgrund. Krankheit: ab 2. vollem Abwesenheitsmonat pro Dienstjahr pro weiteren Monat −1/12. **Mitigation**: Logik parametrisiert pro `absence_type_code` (`affects_vacation_accrual` BOOL) + manueller Override-Approval durch GF.

### 10.5 Datenschutz bei Mobile-Timer
Standort-/IP-Logging bei Mobile-Timer fällt unter revDSG (ab 1.9.2023) + DSGVO (wenn EU-Kandidaten-Tracking). **Zweckbindung**: nur Zeiterfassungs-Zweck, keine Leistungskontrolle per Art. 26 revDSG. **Mitigation**: Standort-Tracking in Phase 1 nicht aktivieren, in Phase 3.5 als explizites Opt-in mit DSFA.

### 10.6 Retention (ArG 73 Abs. 2 / revDSG)
**5-Jahres-Aufbewahrung** nach Ende der Gültigkeit ist Pflicht-Minimum. Gleichzeitig revDSG-Löschpflicht nach Zweckerreichung. **Lösung**: Retention-Tag `retention_until = date + 5 Jahre`, Lösch-Job läuft nightly, löscht Personenbezug (aber aggregierte Statistiken bleiben pseudonymisiert). Krank-Daten (besondere Personendaten nach Art. 5 lit. c Ziff. 2 revDSG) erhalten verkürzte Retention nach Vertragsende + 5 Jahre, danach sofortige Löschung ohne Pseudonymisierungs-Fallback.

### 10.7 Beweislast Überzeit (BGE 4A_227/2017, 4A_482/2017, 4A_29/2023)
Ohne ordnungsgemässe Zeiterfassung trägt AG faktisch das Beweisrisiko; MA-Eigenaufzeichnungen werden als Beweismittel zugelassen (keine echte Umkehr, aber Erleichterung). Der Richter kann nach Art. 42 Abs. 2 OR analog schätzen. **Produkt-Anti-Risk**: vollständiger Audit-Trail auf jeder Mutation, tamper-evident JSONB-Log, Export-Bestätigung gegenüber MA (Monatszettel-PDF mit Unterschriften-Workflow).

### 10.8 TRUST-Modell vs. Dokumentationspflicht
Interne „Vertrauensarbeitszeit" darf rechtlich nicht bedeuten „keine Erfassung". **Workaround**: TRUST-MA erfassen vereinfacht nach Art. 73b (nur Tagessumme, kein Start/Ende) — sofern Autonomie >50% und Sozialpartner-Vereinbarung besteht. System muss erzwingen, dass bei `work_time_model=TRUST` automatisch `SIMPLIFIED`-Erfassung aktiviert wird oder Warn-UI zeigt.

### 10.9 Elektronische Signatur Art. 73b-Vereinbarung
Schweizer OR Art. 13/14 verlangt für Schriftform eigenhändige oder QES-Unterschrift. Einfache Klick-Zustimmung reicht nicht. **Mitigation**: PDF-Template mit DocuSign-QES (anerkannter Zertifizierungsdienst nach ZertES, z.B. Swisscom Signing Service) oder handschriftlich + Scan-Upload.

### 10.10 Feiertag 1.8.2026 und 26.12.2026 auf Samstag
ArG/ZH sieht keinen Ersatztag vor. Für 5-Tage-Woche-MA (Mo–Fr) = kein wirtschaftlicher Effekt. Für 6-Tage-MA (Samstag-Arbeit) = Feiertag fällt ins Wochenende, verloren. **Empfehlung**: Firmenregel „Feiertag auf Sa/So kompensiert mit freiem Brückentag" dokumentieren oder bewusst nicht gewähren — `fact_holiday_cantonal.half_day=false` + Policy-Flag `compensate_weekend_holidays`.

### 10.11 Bettag-Montag in ZH
Der dritte Sonntag im September ist Eidg. Bettag — im Kt. Zürich gibt es **keinen arbeitsfreien Montag danach** (anders als VD „Lundi du Jeûne"). System darf 21.9.2026 nicht automatisch als Feiertag markieren.

### 10.12 Commission-Engine-ZEG in Phase 2
Wenn Phase 2 live geht und `project_id` retrospektiv pflichtig wird, entstehen Datenlücken für Phase-1-Periode. **Mitigation**: Migration-Plan mit optionaler Nach-Zuordnung durch MA (Self-Service) + GF-Freigabe; oder ZEG-Berechnung nur ab Cut-Over-Datum mit Wasserzeichen auf historischen Zeiten.

## Fazit

Das Zeiterfassungs-Modul muss in einer KMU ohne GAV auf **Art. 73b ArGV 1** (vereinfachte Erfassung) aufbauen — ein echter Verzicht nach Art. 73a ist strukturell ausgeschlossen. Die Architektur ist **schema-zukunftsfähig** für Commission-Engine-ZEG-Integration via nullable `project_id` und ELM-5.0-Export, während Phase 1 auf robuste Erfassung, Approval-Workflows und Treuhand-Exports (Bexio-CSV + generisches CSV + ELM 5.0) fokussiert. **Kritischer Erfolgsfaktor**: lückenloser Audit-Trail (ArG 46/73, 5-Jahres-Retention) — denn ohne ordnungsgemässe Erfassung trägt die Boutique gemäss BGer-Rechtsprechung das Beweisrisiko bei Überstunden-Streitigkeiten.