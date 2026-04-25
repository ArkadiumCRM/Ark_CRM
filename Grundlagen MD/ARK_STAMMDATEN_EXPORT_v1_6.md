# ARK CRM — Stammdaten-Export v1.6

**Stand:** 2026-04-25
**Vorgänger:** v1.5 (2026-04-24 · E-Learning + HR) / v1.4 (2026-04-19) / v1.3 (2026-04-14)
**Scope v1.6:** Performance-Modul-Stammdaten (TEIL §97 · Cross-Modul-Analytics-Hub · ~33 Metric-Defs · 15 Anomaly-Thresholds · 15 Tile-Types · 5 Report-Templates · 8 PowerBI-Views · `dim_process_stages`+`dim_user`-Erweiterungen)
**Scope v1.5:** Activity-Types-Patch + E-Learning-Modul A/B/C/D + HR-Modul (TEIL §96)

## Änderungen v1.2 → v1.3

Resultiert aus dem Komplett-Audit (`wiki/analyses/audit-2026-04-13-komplett.md`) + Entscheidungen 2026-04-14 (`wiki/analyses/audit-entscheidungen-2026-04-14.md`).

**15 neue Stammdaten-Tabellen** (Sektionen 51–65):

| # | Tabelle | Zweck | Tier |
|---|---------|-------|------|
| 51 | `dim_assessment_types` | Typen-Katalog für Assessment-Credits (MDI/Relief/ASSESS 5.0/DISC/EQ/Scheelen 6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad) | P0 |
| 52 | `dim_rejection_reasons_internal` | Prozess-interne Ablehnungsgründe (bei `rejected_by='internal'`) | P0 |
| 53 | `dim_honorar_settings` | Erfolgsbasis-Staffel (21/23/25/27%) — dokumentiert | P0 |
| 54 | `dim_culture_dimensions` | 6 Kultur-Analyse-Dimensionen | P0 |
| 55 | `dim_sia_phases` | SIA 112: 6 Haupt- + 12 Teilphasen hierarchisch | P0 |
| 56 | `dim_dropped_reasons` | Prozess-Drop-Gründe (Prozess kam nie zustande) | P0 |
| 57 | `dim_cancellation_reasons` | Rückzieher-nach-Placement-Gründe | P1 |
| 58 | `dim_offer_refused_reasons` | Angebotsablehnungs-Gründe | P1 |
| 59 | `dim_vacancy_rejection_reasons` | Scraper-Proposal-Ablehnungsgründe | P1 |
| 60 | `dim_scraper_types` | Scraper-Typen-Registry (7 Typen Phase 1) | P1 |
| 61 | `dim_scraper_global_settings` | Admin-Settings Scraper | P1 |
| 62 | `dim_matching_weights` | Job-Kandidat-Matching-Gewichte | P1 |
| 63 | `dim_matching_weights_project` | Projekt-Kandidat-Matching-Gewichte | P1 |
| 64 | `dim_reminder_templates` | Reminder-Vorlagen | P2 |
| 65 | `dim_time_packages` | Time-Mandat-Pakete (Entry/Medium/Pro) | P2 |
| 66 | Erweiterungen `dim_automation_settings` | Neue Keys für Schwellen/Limits | P1 |

**Globale Konventionen:**
- **Sprachstandard:** `candidate_id` (englisch), nicht `kandidat_id`
- **Routen englisch:** `/candidates`, `/accounts`, `/mandates`, `/jobs`, `/processes`, `/assessments`, `/scraper`, **`/company-groups`**, **`/projects`**
- **Status-Enums Sprache gemischt (intentional):** Mandat + Job deutsch, Prozess + Assessment englisch (siehe Wiki `status-enum-katalog.md`, ausstehend)
- **`fact_jobs`** (operativ) — kein `dim_jobs`
- **SIA-Phasen:** 6 Haupt- + 12 Teilphasen (nicht 11)

**Archiv:** v1.2 bleibt als `ARK_STAMMDATEN_EXPORT_v1_2.md` erhalten.

---

# TEIL A: Bestehende Stammdaten v1.2 (unverändert übernommen)

**Original-Änderungen v1.2:** Activity-Types komplett überarbeitet (61+ in 11 Kategorien), Email-Templates (32), Jobbasket-Rejection-Types, Automation-Settings, Cancellation-Reasons korrigiert, Wechselmotivation-Stufen, Kandidaten-Stages aktualisiert

---

## 1. EDV / Software-Skills (dim_edv)

| ID | Name | Kategorie |
|-----|------|----------|
| edv_040 | Arriba | AVA / Kalkulation |
| edv_038 | Baubit Pro | AVA / Kalkulation |
| edv_047 | Conpilot | AVA / Kalkulation |
| edv_045 | CostX | AVA / Kalkulation |
| edv_046 | Cosuno | AVA / Kalkulation |
| edv_044 | Delta Bau | AVA / Kalkulation |
| edv_043 | DELTAproject | AVA / Kalkulation |
| edv_034 | iTWO 4.0 | AVA / Kalkulation |
| edv_035 | iTWO Site | AVA / Kalkulation |
| edv_039 | Messerli | AVA / Kalkulation |
| edv_037 | NEVARIS Build | AVA / Kalkulation |
| edv_048 | Olmero | AVA / Kalkulation |
| edv_036 | ORCA AVA | AVA / Kalkulation |
| edv_033 | RIB iTWO | AVA / Kalkulation |
| edv_041 | Sorba | AVA / Kalkulation |
| edv_049 | Take-Off | AVA / Kalkulation |
| edv_042 | WinBau | AVA / Kalkulation |
| edv_004 | Allplan | BIM / CAD |
| edv_001 | ArchiCAD 2D | BIM / CAD |
| edv_002 | ArchiCAD 3D | BIM / CAD |
| edv_010 | AutoCAD | BIM / CAD |
| edv_011 | AutoCAD MEP | BIM / CAD |
| edv_018 | Autodesk Forma | BIM / CAD |
| edv_008 | Autodesk InfraWorks | BIM / CAD |
| edv_003 | Autodesk Revit | BIM / CAD |
| edv_013 | Cadwork | BIM / CAD |
| edv_017 | Catia | BIM / CAD |
| edv_012 | Civil 3D | BIM / CAD |
| edv_006 | MicroStation | BIM / CAD |
| edv_007 | OpenRoads Designer | BIM / CAD |
| edv_014 | PLANBAR | BIM / CAD |
| edv_015 | Rhinoceros | BIM / CAD |
| edv_016 | Solid Works | BIM / CAD |
| edv_005 | Tekla Structures | BIM / CAD |
| edv_009 | VectorWorks | BIM / CAD |
| edv_021 | BIM360 | BIM Koordination |
| edv_023 | BIMVision | BIM Koordination |
| edv_026 | Bluebeam | BIM Koordination |
| edv_024 | COBie | BIM Koordination |
| edv_025 | IFC | BIM Koordination |
| edv_019 | Navisworks | BIM Koordination |
| edv_022 | Revizto | BIM Koordination |
| edv_020 | Solibri | BIM Koordination |
| edv_077 | Abacus | ERP / Finanzen |
| edv_082 | Allfa | ERP / Finanzen |
| edv_083 | CAE | ERP / Finanzen |
| edv_079 | NAV Microsoft Dynamics | ERP / Finanzen |
| edv_080 | NOVA | ERP / Finanzen |
| edv_081 | PROVI | ERP / Finanzen |
| edv_078 | SAP | ERP / Finanzen |
| edv_051 | DDScad | Gebäudetechnik |
| edv_057 | Dialux | Gebäudetechnik |
| edv_062 | ECSCAD | Gebäudetechnik |
| edv_066 | Eismann | Gebäudetechnik |
| edv_060 | EPLAN | Gebäudetechnik |
| edv_061 | ePlan Electric | Gebäudetechnik |
| edv_056 | Flixo | Gebäudetechnik |
| edv_053 | IDA ICE | Gebäudetechnik |
| edv_055 | Lesosai | Gebäudetechnik |
| edv_050 | MagiCAD | Gebäudetechnik |
| edv_067 | Niagara | Gebäudetechnik |
| edv_063 | Optiplan-Smart | Gebäudetechnik |
| edv_054 | Plancal Nova | Gebäudetechnik |
| edv_052 | Polysun | Gebäudetechnik |
| edv_064 | ProPlanner | Gebäudetechnik |
| edv_058 | Relux | Gebäudetechnik |
| edv_068 | Siemens S7 | Gebäudetechnik |
| edv_059 | Simaris | Gebäudetechnik |
| edv_065 | Vago | Gebäudetechnik |
| edv_085 | ArcGIS | GIS / Vermessung |
| edv_086 | ArcView | GIS / Vermessung |
| edv_090 | Basement | GIS / Vermessung |
| edv_091 | Delphin | GIS / Vermessung |
| edv_088 | Dlubal | GIS / Vermessung |
| edv_089 | HEC-RAS | GIS / Vermessung |
| edv_084 | QGIS | GIS / Vermessung |
| edv_092 | SIA-Tec-Tool | GIS / Vermessung |
| edv_087 | Trimble | GIS / Vermessung |
| edv_101 | Adobe Photoshop | Grafik / Design |
| edv_103 | Affinity Designer | Grafik / Design |
| edv_104 | Fresco | Grafik / Design |
| edv_102 | Illustrator | Grafik / Design |
| edv_072 | AbaImmo | Immobilien ERP |
| edv_076 | Argus Estate | Immobilien ERP |
| edv_073 | Fairwalter | Immobilien ERP |
| edv_069 | GARAIO REM | Immobilien ERP |
| edv_071 | ImmoTop2 | Immobilien ERP |
| edv_075 | MRI Software | Immobilien ERP |
| edv_070 | Rimo R5 | Immobilien ERP |
| edv_074 | Yardi | Immobilien ERP |
| edv_105 | MS Office | Office / Allgemein |
| edv_107 | Power Automate | Office / Allgemein |
| edv_106 | Power BI | Office / Allgemein |
| edv_108 | Visio | Office / Allgemein |
| edv_100 | Braso | Projektmanagement |
| edv_095 | Fasttrack Schedule | Projektmanagement |
| edv_094 | Merlin Project | Projektmanagement |
| edv_096 | Monday.com | Projektmanagement |
| edv_093 | MS Project | Projektmanagement |
| edv_099 | PlanRadar | Projektmanagement |
| edv_098 | Procore | Projektmanagement |
| edv_097 | SharePoint | Projektmanagement |
| edv_032 | Cinema 4D | Visualisierung |
| edv_029 | Enscape | Visualisierung |
| edv_028 | Lumion | Visualisierung |
| edv_031 | SketchUp | Visualisierung |
| edv_027 | Twinmotion | Visualisierung |
| edv_030 | V-Ray | Visualisierung |

---

## 2. Funktionen (dim_functions)

| ID | Name | Kategorie | Level | Parent |
|-----|------|----------|-------|--------|
| fun_140 | Real Estate Analyst | Analyse | Mid |  |
| fun_139 | Real Estate Researcher | Analyse | Mid | fun_140 |
| fun_177 | Assetmanager | Asset & Portfolio Mgmt | Senior | fun_128 |
| fun_128 | Portfoliomanager | Asset & Portfolio Mgmt | Senior |  |
| fun_129 | Senior Tenant-/Asset-Manager | Asset & Portfolio Mgmt | Senior | fun_128 |
| fun_043 | Bauführer | Bauführung | Senior |  |
| fun_046 | Baumeister | Bauführung | Senior | fun_043 |
| fun_049 | Equipenleiter | Bauführung | Mid | fun_043 |
| fun_048 | Gruppenführer | Bauführung | Mid | fun_043 |
| fun_045 | Junior Bauführer | Bauführung | Junior | fun_043 |
| fun_047 | Polier | Bauführung | Mid | fun_043 |
| fun_044 | Senior Bauführer | Bauführung | Senior | fun_043 |
| fun_050 | Vorarbeiter | Bauführung | Mid | fun_043 |
| fun_119 | Bauherrenberater | Bauherrenberatung | Senior |  |
| fun_120 | Bauherrenvertreter | Bauherrenberatung | Senior | fun_119 |
| fun_015 | Baukostenplaner | Bauökonomie | Senior | fun_016 |
| fun_016 | Bauökonom | Bauökonomie | Senior |  |
| fun_017 | Deviseur | Bauökonomie | Mid | fun_016 |
| fun_105 | Kalkulator | Bauökonomie | Mid | fun_016 |
| fun_175 | Consultant | Beratung | Mid |  |
| fun_137 | Immobilienberater | Beratung | Senior |  |
| fun_138 | Strategy Consulting Real Estate | Beratung | Senior |  |
| fun_143 | Immobilienbewerter | Bewertung | Mid | fun_142 |
| fun_144 | Immobilienschätzer | Bewertung | Mid | fun_142 |
| fun_142 | Real Estate Valuation Manager | Bewertung | Senior |  |
| fun_148 | Flächenmanager | Bewirtschaftung | Mid |  |
| fun_145 | Immobilienbewirtschafter | Bewirtschaftung | Mid |  |
| fun_131 | Objektmanager | Bewirtschaftung | Mid | fun_147 |
| fun_147 | Propertymanager | Bewirtschaftung | Mid |  |
| fun_182 | Dozent | Bildung | Mid |  |
| fun_029 | BIM Architekt | BIM & Digital | Senior | fun_118 |
| fun_037 | BIM Konstrukteur | BIM & Digital | Mid | fun_118 |
| fun_117 | BIM Koordinator | BIM & Digital | Senior | fun_118 |
| fun_118 | BIM Manager | BIM & Digital | Executive |  |
| fun_038 | BIM Modellierer | BIM & Digital | Mid | fun_118 |
| fun_030 | BIM Spezialist | BIM & Digital | Senior | fun_118 |
| fun_032 | Datenexperte BIM | BIM & Digital | Senior | fun_118 |
| fun_031 | Revit Spezialist | BIM & Digital | Mid | fun_118 |
| fun_188 | Data Analyst | Digitalisierung | Mid |  |
| fun_178 | Einkäufer | Einkauf | Mid |  |
| fun_181 | Lead Buyer | Einkauf | Senior | fun_178 |
| fun_180 | Operativer Einkäufer | Einkauf | Mid | fun_178 |
| fun_179 | Strategischer Einkäufer | Einkauf | Senior | fun_178 |
| fun_125 | Facility Manager | Facility Management | Senior |  |
| fun_126 | Head Move & Infrastructure Services | Facility Management | Executive |  |
| fun_127 | Manager Infrastruktur Immobilien | Facility Management | Senior | fun_125 |
| fun_153 | Buchhalter | Finanzen | Mid |  |
| fun_152 | Immobilienbuchhalter | Finanzen | Mid | fun_153 |
| fun_151 | Liegenschaftsbuchhalter | Finanzen | Mid | fun_153 |
| fun_072 | Betriebsleiter | Führung | Senior |  |
| fun_083 | Leiter Anlagenplanung | Führung | Senior |  |
| fun_007 | Leiter Architektur | Führung | Executive |  |
| fun_033 | Leiter Ausführung | Führung | Executive |  |
| fun_011 | Leiter Baukostenplanung | Führung | Executive |  |
| fun_008 | Leiter Baumanagement | Führung | Executive |  |
| fun_012 | Leiter Baumeister | Führung | Executive |  |
| fun_146 | Leiter Bewirtschaftung | Führung | Senior |  |
| fun_085 | Leiter Einkauf | Führung | Senior |  |
| fun_094 | Leiter Elektromobilität | Führung | Senior |  |
| fun_090 | Leiter Energiedienstleistung | Führung | Senior |  |
| fun_010 | Leiter Entwicklung | Führung | Executive |  |
| fun_096 | Leiter Heizung | Führung | Senior |  |
| fun_084 | Leiter Immobilien | Führung | Executive |  |
| fun_095 | Leiter Netz | Führung | Senior |  |
| fun_082 | Leiter Technisches Büro | Führung | Senior |  |
| fun_022 | Planungsleiter | Führung | Executive |  |
| fun_086 | Senior Environmental Manager | Führung | Senior |  |
| fun_107 | Strategischer Assetmanager Energie | Führung | Senior |  |
| fun_169 | Teamleiter | Führung | Mid |  |
| fun_154 | Technischer Leiter | Führung | Senior |  |
| fun_160 | Abteilungsleiter | Führung Executive | Executive |  |
| fun_161 | Bereichsleiter | Führung Executive | Executive |  |
| fun_158 | Geschäftsführer | Führung Executive | C-Suite |  |
| fun_164 | Inhaber | Führung Executive | C-Suite |  |
| fun_159 | Niederlassungsleiter | Führung Executive | Executive |  |
| fun_162 | Regionalleiter | Führung Executive | Executive |  |
| fun_163 | Verwaltungsrat | Führung Executive | C-Suite |  |
| fun_157 | Family Office Manager | Investment | Senior |  |
| fun_176 | Investment Manager | Investment | Senior | fun_128 |
| fun_141 | Real Estate Investment Manager | Investment | Senior |  |
| fun_156 | Corporate Real Estate Manager | Management | Senior |  |
| fun_187 | ESG Manager | Nachhaltigkeit | Senior |  |
| fun_087 | Manager Corporate Responsibility & Nachhaltigkeit | Nachhaltigkeit | Senior |  |
| fun_186 | Nachhaltigkeitsbeauftragter | Nachhaltigkeit | Senior | fun_187 |
| fun_001 | Architekt | Planung & Engineering | Senior |  |
| fun_034 | Bauingenieur | Planung & Engineering | Senior |  |
| fun_058 | Bauphysiker | Planung & Engineering | Senior |  |
| fun_013 | Bautechniker | Planung & Engineering | Mid |  |
| fun_053 | Bauvermesser | Planung & Engineering | Mid |  |
| fun_039 | CAD Konstrukteur | Planung & Engineering | Mid | fun_190 |
| fun_040 | CAD Koordinator | Planung & Engineering | Mid | fun_190 |
| fun_091 | Elektroplaner | Planung & Engineering | Senior | fun_190 |
| fun_065 | Energieanalyst | Planung & Engineering | Mid | fun_064 |
| fun_088 | Energieberater | Planung & Engineering | Senior |  |
| fun_064 | Energiemanager | Planung & Engineering | Senior |  |
| fun_100 | Gebäudetechnikplaner Gebäudeautomation | Planung & Engineering | Mid | fun_190 |
| fun_097 | Gebäudetechnikplaner Heizung | Planung & Engineering | Mid | fun_190 |
| fun_099 | Gebäudetechnikplaner Lüftung | Planung & Engineering | Mid | fun_190 |
| fun_098 | Gebäudetechnikplaner Sanitär | Planung & Engineering | Mid | fun_190 |
| fun_060 | Geograph | Planung & Engineering | Mid |  |
| fun_059 | Geologe | Planung & Engineering | Senior |  |
| fun_052 | Geomatiker | Planung & Engineering | Mid | fun_051 |
| fun_051 | Geomatikingenieur | Planung & Engineering | Senior |  |
| fun_057 | Holzbauingenieur | Planung & Engineering | Senior |  |
| fun_035 | Ingenieur | Planung & Engineering | Mid |  |
| fun_101 | MSRL Planer | Planung & Engineering | Mid | fun_190 |
| fun_036 | Projektingenieur | Planung & Engineering | Mid |  |
| fun_028 | Raumausstatter | Planung & Engineering | Mid | fun_190 |
| fun_027 | Raumentwickler | Planung & Engineering | Senior | fun_190 |
| fun_026 | Raumplaner | Planung & Engineering | Senior | fun_190 |
| fun_025 | Städteplaner | Planung & Engineering | Senior | fun_190 |
| fun_014 | Techniker | Planung & Engineering | Mid |  |
| fun_054 | Trassierer | Planung & Engineering | Mid |  |
| fun_062 | Umweltberater | Planung & Engineering | Senior | fun_061 |
| fun_063 | Umweltfachspezialist | Planung & Engineering | Mid | fun_061 |
| fun_061 | Umweltingenieur | Planung & Engineering | Senior |  |
| fun_056 | Verfahreningenieur | Planung & Engineering | Senior |  |
| fun_055 | Verkehrsingenieur | Planung & Engineering | Senior |  |
| fun_190 | Zeichner / Planer | Planung & Engineering | Mid |  |
| fun_024 | Zeichner Hochbau | Planung & Engineering | Mid | fun_190 |
| fun_041 | Zeichner Infrastruktur | Planung & Engineering | Mid | fun_190 |
| fun_042 | Zeichner Ingenieurbau | Planung & Engineering | Mid | fun_190 |
| fun_023 | Zeichner Raumplanung | Planung & Engineering | Mid | fun_190 |
| fun_170 | Produktmanager | Produkt & Vertrieb | Mid |  |
| fun_020 | Immobilienentwickler | Projektentwicklung | Senior |  |
| fun_019 | Projektentwickler | Projektentwicklung | Senior |  |
| fun_018 | Bau- und Projektleiter | Projektmanagement | Senior |  |
| fun_002 | Bauleiter | Projektmanagement | Senior |  |
| fun_003 | Chef Bauleiter | Projektmanagement | Executive | fun_002 |
| fun_110 | Fachbauleiter | Projektmanagement | Senior | fun_002 |
| fun_166 | Gesamtprojektleiter | Projektmanagement | Executive |  |
| fun_006 | Junior Bauleiter | Projektmanagement | Junior | fun_002 |
| fun_167 | Junior Projektleiter | Projektmanagement | Junior | fun_165 |
| fun_189 | Lean Manager | Projektmanagement | Senior |  |
| fun_081 | Mandatsleiter Infrastrukturprüfung | Projektmanagement | Senior |  |
| fun_004 | Oberbauleiter | Projektmanagement | Executive | fun_002 |
| fun_071 | Objektleiter | Projektmanagement | Senior |  |
| fun_165 | Projektleiter | Projektmanagement | Senior |  |
| fun_005 | Senior Bauleiter | Projektmanagement | Senior | fun_002 |
| fun_168 | Senior Projektleiter | Projektmanagement | Senior | fun_165 |
| fun_066 | Brandschutzexperte | Sicherheit | Senior |  |
| fun_067 | Brandschutzfachmann | Sicherheit | Mid | fun_066 |
| fun_104 | Brandschutzplaner | Sicherheit | Senior | fun_066 |
| fun_068 | Sicherheitsbeauftragter | Sicherheit | Mid |  |
| fun_069 | Spezialist Arbeitssicherheit und Umweltschutz | Sicherheit | Mid |  |
| fun_114 | Automatiker | Spezialist | Mid |  |
| fun_077 | Baumaschinenführer | Spezialist | Mid |  |
| fun_076 | Baustoffprüfer | Spezialist | Mid |  |
| fun_075 | Bauwerkserhalter | Spezialist | Mid |  |
| fun_074 | Bauwerktrenner | Spezialist | Mid |  |
| fun_109 | Chefmonteur | Spezialist | Senior |  |
| fun_092 | Elektroinstallateur | Spezialist | Mid |  |
| fun_106 | Energieverantwortlicher | Spezialist | Mid |  |
| fun_070 | Fachspezialist | Spezialist | Mid |  |
| fun_089 | Feuerungskontroller | Spezialist | Mid |  |
| fun_102 | Heizwerkführer | Spezialist | Mid |  |
| fun_111 | Inspektor | Spezialist | Mid |  |
| fun_112 | Installateur | Spezialist | Mid |  |
| fun_079 | Klärwerkfachmann | Spezialist | Mid |  |
| fun_093 | Netzelektrikmeister | Spezialist | Senior |  |
| fun_113 | Polymechaniker | Spezialist | Mid |  |
| fun_080 | Spezialist Energiewirtschaft | Spezialist | Senior |  |
| fun_078 | Spezialist Kunstharzbeläge | Spezialist | Mid |  |
| fun_115 | Systemtechniker | Spezialist | Mid |  |
| fun_103 | Wärmepumpenfachmann | Spezialist | Mid |  |
| fun_116 | Wissenschaftlicher Mitarbeiter | Spezialist | Mid |  |
| fun_184 | Assistent | Support | Junior |  |
| fun_183 | Sachbearbeiter | Support | Mid |  |
| fun_124 | Acquisitions Specialist | Transaktionen | Senior |  |
| fun_122 | Senior Real Estate Transaction Manager | Transaktionen | Senior | fun_121 |
| fun_123 | Transaction Advisory | Transaktionen | Senior |  |
| fun_121 | Transaction Manager | Transaktionen | Senior |  |
| fun_150 | Immobilientreuhändler | Treuhand | Senior |  |
| fun_171 | Account Manager | Vertrieb | Mid |  |
| fun_185 | Akquisiteur | Vertrieb | Mid |  |
| fun_108 | Bid Manager | Vertrieb | Mid |  |
| fun_173 | Business Development Manager | Vertrieb | Senior |  |
| fun_021 | Immobilienmakler | Vertrieb | Mid |  |
| fun_132 | Immobilienvermarkter | Vertrieb | Mid |  |
| fun_149 | Käuferbetreuer | Vertrieb | Mid |  |
| fun_130 | Key Account Manager | Vertrieb | Senior |  |
| fun_135 | Real Estate Broker | Vertrieb | Mid |  |
| fun_133 | Real Estate Marketing Manager | Vertrieb | Senior | fun_172 |
| fun_136 | Relationship Manager | Vertrieb | Senior |  |
| fun_172 | Sales Manager | Vertrieb | Senior |  |
| fun_134 | Sales Manager Real Estate | Vertrieb | Senior | fun_172 |
| fun_174 | Verkäufer | Vertrieb | Mid |  |
| fun_073 | Bauverwalter | Verwaltung | Mid |  |
| fun_155 | Immobilienverwalter | Verwaltung | Mid |  |

---

## 3. Ausbildung (dim_education)

| ID | Name | Level | Feld | Institution |
|-----|------|-------|------|-------------|
| EDU_108 | Handelsschule VSH | Berufsfachschule | Kaufmännisch | Berufsfachschule |
| EDU_502 | SVIT Sachbearbeiterkurs Immobilien | Berufsfachschule | Immobilien | Verband |
| EDU_331 | CAS Akustik | CAS | Bauphysik | Weiterbildung |
| EDU_332 | CAS Angewandte Psychologie | CAS | Management | Weiterbildung |
| EDU_333 | CAS Angewandten Erdwissenschaften | CAS | Natur & Umwelt | Weiterbildung |
| EDU_334 | CAS Bau- und Vergaberecht | CAS | Recht | Weiterbildung |
| EDU_335 | CAS Bauen mit Holz | CAS | Holzbau | Weiterbildung |
| EDU_336 | CAS Bauherrenvertretung | CAS | Bauherrenberatung | Weiterbildung |
| EDU_337 | CAS Bauherrnkompetenz | CAS | Bauherrenberatung | Weiterbildung |
| EDU_338 | CAS Baukostenplanung | CAS | Bauökonomie | Weiterbildung |
| EDU_339 | CAS Baukultur | CAS | Architektur | Weiterbildung |
| EDU_340 | CAS Baumanagement | CAS | Management | Weiterbildung |
| EDU_341 | CAS Bauphysik | CAS | Bauphysik | Weiterbildung |
| EDU_342 | CAS Bauphysik im Holzbau | CAS | Bauphysik | Weiterbildung |
| EDU_343 | CAS Bauprojektmanagement | CAS | Projektmanagement | Weiterbildung |
| EDU_344 | CAS Baurecht | CAS | Recht | Weiterbildung |
| EDU_345 | CAS Bedürfnisgerechtes Planen und Bauen | CAS | Architektur | Weiterbildung |
| EDU_346 | CAS Beratung von Gruppen und Teams | CAS | Management | Weiterbildung |
| EDU_347 | CAS Bestellerkompetenz - Projekt- und Gesamtleitung | CAS | Bauherrenberatung | Weiterbildung |
| EDU_348 | CAS Betontechnik | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_349 | CAS Betriebsoptimierung | CAS | Management | Weiterbildung |
| EDU_350 | CAS Betriebswirtschaft Bau | CAS | Wirtschaft | Weiterbildung |
| EDU_351 | CAS Betriebswirtschaft im Technologieumfeld | CAS | Wirtschaft | Weiterbildung |
| EDU_352 | CAS Brandschutz für ArchitektInnen | CAS | Sicherheit | Weiterbildung |
| EDU_353 | CAS Brandschutz im Holzbau | CAS | Sicherheit | Weiterbildung |
| EDU_354 | CAS Change Management | CAS | Management | Weiterbildung |
| EDU_355 | CAS Climate Innovation | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_356 | CAS Coaching und Unternehmensberatung | CAS | Management | Weiterbildung |
| EDU_357 | CAS Digital Planen, Bauen, Nutzen | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_358 | CAS Digital Real Estate | CAS | Immobilien | Weiterbildung |
| EDU_359 | CAS Digital, Architecture and Building Process | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_360 | CAS Digitales Bauen Strategien und Potentiale | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_361 | CAS Digitalisierung | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_362 | CAS Eisenbahntechnologie | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_363 | CAS Elektrische Energie am Bau | CAS | Energie & Umwelt | Weiterbildung |
| EDU_364 | CAS Energie am Bau | CAS | Energie & Umwelt | Weiterbildung |
| EDU_365 | CAS Energie in der Gebäudeerneuerung | CAS | Energie & Umwelt | Weiterbildung |
| EDU_366 | CAS Energieberatung | CAS | Energie & Umwelt | Weiterbildung |
| EDU_367 | CAS Energiemanagement | CAS | Energie & Umwelt | Weiterbildung |
| EDU_368 | CAS Energieökonomie | CAS | Energie & Umwelt | Weiterbildung |
| EDU_369 | CAS Erdbebensicherheit Bestandbauten | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_370 | CAS Erdbebensicherheit Neubauten | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_371 | CAS Erneuerbare Energien | CAS | Energie & Umwelt | Weiterbildung |
| EDU_373 | CAS Führungskompetenz / Leadership | CAS | Management | Weiterbildung |
| EDU_374 | CAS Führungskompetenz entwickeln | CAS | Management | Weiterbildung |
| EDU_372 | CAS Future Heritage | CAS | Architektur | Weiterbildung |
| EDU_375 | CAS Gebäudemanagement | CAS | Facility Management | Weiterbildung |
| EDU_376 | CAS General Management | CAS | Management | Weiterbildung |
| EDU_377 | CAS Generative künstliche Intelligenz | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_378 | CAS GeoBIM | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_379 | CAS Geoinformationssysteme und -analysen | CAS | Vermessung | Weiterbildung |
| EDU_380 | CAS Gesamtprojektleitung | CAS | Management | Weiterbildung |
| EDU_381 | CAS Grund- und Spezialtiefbau | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_382 | CAS Grundlagen der Betriebswirtschaftslehre | CAS | Wirtschaft | Weiterbildung |
| EDU_383 | CAS Grundlagen in systemischer Mediation | CAS | Management | Weiterbildung |
| EDU_384 | CAS Holztragwerke | CAS | Holzbau | Weiterbildung |
| EDU_385 | CAS Immobilienbewertung | CAS | Immobilien | Weiterbildung |
| EDU_386 | CAS Immobilienökonomie | CAS | Immobilien | Weiterbildung |
| EDU_387 | CAS Immobilienstrategien urban-peri-urban | CAS | Immobilien | Weiterbildung |
| EDU_388 | CAS Information Security | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_389 | CAS Innenarchitektur | CAS | Architektur | Weiterbildung |
| EDU_390 | CAS innovations- und Changemanager | CAS | Management | Weiterbildung |
| EDU_391 | CAS integrale Gebäudetechnik und Energie | CAS | Gebäudetechnik | Weiterbildung |
| EDU_392 | CAS International Accounting and Reporting | CAS | Wirtschaft | Weiterbildung |
| EDU_393 | CAS Kommunale Infrastruktur | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_394 | CAS Kommunikation und Führung im Bauwesen | CAS | Management | Weiterbildung |
| EDU_395 | CAS Kompetenzorientiertes Projektmanagement | CAS | Projektmanagement | Weiterbildung |
| EDU_396 | CAS Kostenplanung | CAS | Bauökonomie | Weiterbildung |
| EDU_397 | CAS Leadership | CAS | Management | Weiterbildung |
| EDU_398 | CAS Leadership Advanced | CAS | Management | Weiterbildung |
| EDU_399 | CAS Life Cycle Management Immobilien | CAS | Immobilien | Weiterbildung |
| EDU_400 | CAS Methoden und Technologien im Digitalen Bauen | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_401 | CAS Nachhaltiges Bauen | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_402 | CAS Naturgefahren-Risikomanagement | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_403 | CAS Photovoltaik | CAS | Energie & Umwelt | Weiterbildung |
| EDU_404 | CAS Potentiale und Strategien im Digitalen Bauen | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_405 | CAS Projektmanagement | CAS | Projektmanagement | Weiterbildung |
| EDU_406 | CAS Projektmanager Bau | CAS | Projektmanagement | Weiterbildung |
| EDU_407 | CAS Public Administration | CAS | Management | Weiterbildung |
| EDU_410 | CAS Raumentwicklung und Planungspraxis | CAS | Raumplanung | Weiterbildung |
| EDU_411 | CAS Raumentwicklung und Prozessdesign | CAS | Raumplanung | Weiterbildung |
| EDU_408 | CAS Raumplanung | CAS | Raumplanung | Weiterbildung |
| EDU_409 | CAS Raumplanung ETH | CAS | Raumplanung | Weiterbildung |
| EDU_412 | CAS Real Estate Asset Management | CAS | Immobilien | Weiterbildung |
| EDU_413 | CAS Real Estate Development | CAS | Immobilien | Weiterbildung |
| EDU_414 | CAS Real Estate Investment Management | CAS | Immobilien | Weiterbildung |
| EDU_415 | CAS Recht der Denkmalpflege und des Heimatschutzes | CAS | Recht | Weiterbildung |
| EDU_416 | CAS Regenerative Materials - Essentials | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_417 | CAS Regenerative Materials - Hygrothermal Specialisation | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_418 | CAS Regenerative Materials - Structural Specialisation | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_419 | CAS Regenerative Systems: Sustainability to Regeneration | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_420 | CAS Repair and Maintenance | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_421 | CAS Schutz und Instandsetzung von Betonbauten | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_422 | CAS Seismic Evaluation and Retrofitting | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_423 | CAS Siedlungsentwässerung | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_424 | CAS Städtebau | CAS | Raumplanung | Weiterbildung |
| EDU_425 | CAS Stadtraum Landschaft | CAS | Raumplanung | Weiterbildung |
| EDU_426 | CAS Stadtraum Strasse | CAS | Raumplanung | Weiterbildung |
| EDU_441 | CAS Strassenverkehrsanlagen und Geotechnik | CAS | Bauingenieurwesen | Weiterbildung |
| EDU_427 | CAS Strategische Bauerneuerung | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_428 | CAS Strategisches Projektmanagement | CAS | Projektmanagement | Weiterbildung |
| EDU_429 | CAS Teams erfolgreich steuern und begleiten | CAS | Management | Weiterbildung |
| EDU_430 | CAS Thermische Netze | CAS | Energie & Umwelt | Weiterbildung |
| EDU_431 | CAS Unternehmensführung | CAS | Management | Weiterbildung |
| EDU_432 | CAS Unternehmensführung & digitales Management | CAS | Management | Weiterbildung |
| EDU_433 | CAS Unternehmensführung für Architekten und Ingenieure | CAS | Management | Weiterbildung |
| EDU_434 | CAS Urban Management UZH | CAS | Raumplanung | Weiterbildung |
| EDU_435 | CAS Vegetationsanalyse und Feldbotanik | CAS | Natur & Umwelt | Weiterbildung |
| EDU_436 | CAS Virtual Design and Construction | CAS | Digitalisierung Bau | Weiterbildung |
| EDU_437 | CAS Weiterbauen am Bestand | CAS | Bau Spezialgebiet | Weiterbildung |
| EDU_438 | CAS Wertschöpfung und Innovation | CAS | Management | Weiterbildung |
| EDU_439 | CAS Zirkuläres Bauen | CAS | Nachhaltigkeit | Weiterbildung |
| EDU_440 | CAS Zukunft der Raumentwicklung | CAS | Raumplanung | Weiterbildung |
| EDU_442 | DAS Baumanagement | DAS | Management | Weiterbildung |
| EDU_443 | DAS Bauökonomie | DAS | Bauökonomie | Weiterbildung |
| EDU_444 | DAS Bauphysik | DAS | Bauphysik | Weiterbildung |
| EDU_445 | DAS Bauverwalter | DAS | Management | Weiterbildung |
| EDU_446 | DAS Betoningenieur | DAS | Bauingenieurwesen | Weiterbildung |
| EDU_447 | DAS Business Administration | DAS | Wirtschaft | Weiterbildung |
| EDU_448 | DAS Energetische Betriebsoptimierung | DAS | Energie & Umwelt | Weiterbildung |
| EDU_449 | DAS Energieexperte | DAS | Energie & Umwelt | Weiterbildung |
| EDU_450 | DAS Energiemanagement | DAS | Energie & Umwelt | Weiterbildung |
| EDU_451 | DAS Facility Management, Energie-, Gebäudetechnik, Life | DAS | Facility Management | Weiterbildung |
| EDU_452 | DAS Finanzen und Recht im Immobilienmanagement | DAS | Immobilien | Weiterbildung |
| EDU_453 | DAS Gebäudebewirtschaftung | DAS | Facility Management | Weiterbildung |
| EDU_454 | DAS Immobilienmanagement | DAS | Immobilien | Weiterbildung |
| EDU_455 | DAS KMU Management | DAS | Management | Weiterbildung |
| EDU_456 | DAS Raumplanung ETH | DAS | Raumplanung | Weiterbildung |
| EDU_457 | DAS Regenerative Materials | DAS | Nachhaltigkeit | Weiterbildung |
| EDU_194 | Dipl. Bauleiter Hochbau | Dipl. | Bauleitung | Höhere Fachschule |
| EDU_198 | Dipl. Bewirtschaftungsassistent SVIT | Dipl. | Immobilien | Verband |
| EDU_195 | Dipl. Oek. Betriebsökonom | Dipl. | Wirtschaft | Höhere Fachschule |
| EDU_196 | Dipl. Verkaufskoordinator | Dipl. | Kaufmännisch | Höhere Fachschule |
| EDU_197 | Höheres Wirtschaftsdiplom | Dipl. | Wirtschaft | Höhere Fachschule |
| EDU_313 | Bauingenieurwesen Ph.D. | Doktorat | Bauingenieurwesen | ETH / Universität |
| EDU_316 | Elektroengineering Doktor FH | Doktorat | Gebäudetechnik | Fachhochschule |
| EDU_600 | Ph.D Bauingenieurwesen | Doktorat | Bauingenieurwesen |  |
| EDU_324 | Philosophie Natural Doktor Universität | Doktorat | Natur & Umwelt | ETH / Universität |
| EDU_001 | Abdichter EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_002 | Abdichtungspraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_003 | Agrarpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_004 | Anlagen- und Apparatebauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_005 | Architekturmodellbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_006 | Automatiker/in EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_007 | Automatikmonteur EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_008 | Baumaschinenmechaniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_009 | Baupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_010 | Bauwerktrenner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_011 | Betonwerker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_012 | Betriebsinformatiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_013 | Boden-Parkettleger EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_014 | Bootbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_015 | Dachdecker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_016 | Dachdeckerpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_017 | Elektroinstallateur EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_020 | Elektromonteur EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_018 | Elektroniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_019 | Elektroplaner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_022 | Entwässerungspraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_023 | Entwässerungstechnologe EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_024 | Fachmann Betriebsunterhalt EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_025 | Fachmann Information u. Dokumentation EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_021 | Fahrzeugelektriker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_026 | Fassadenbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_027 | Fassadenbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_028 | Forstpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_029 | Forstwart EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_030 | Gärtner EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_031 | Gärtner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_032 | Gebäudeinformatiker EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_033 | Gebäudereiniger EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_034 | Gebäudereiniger EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_035 | Gebäudetechnikplaner Heizung EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_036 | Gebäudetechnikplaner Lüftung EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_037 | Gebäudetechnikplaner Sanitär EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_038 | Geomatiker EFZ | EFZ/EBA | Vermessung | Berufliche Grundbildung |
| EDU_039 | Gerüstbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_040 | Gerüstbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_041 | Gipser-Trockenbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_042 | Gipserpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_043 | Glaser EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_044 | Gleisbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_045 | Gleisbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_046 | Grundbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_047 | Grundbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_048 | Haustechnikpraktiker EBA | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_049 | Heizungsinstallateur EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_050 | Holzbearbeiter EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_051 | Holzbildhauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_052 | Holzhandwerker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_053 | Holzindustriefachmann EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_054 | Hörsystemakustiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_055 | ICT-Fachmann EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_056 | Industrie- und Unterlagsbodenbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_057 | Industrie- und Unterlagsbodenbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_058 | Industriekeramiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_059 | Informatiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_060 | Isolierspengler EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_061 | Kältemontage-Praktiker EBA | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_062 | Kältesystem-Monteur EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_063 | Kältesystem-Planer EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_064 | Kaminfeger EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_065 | Kaufmann EFZ | EFZ/EBA | Kaufmännisch | Berufliche Grundbildung |
| EDU_066 | Küfer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_067 | Landmaschinenmechaniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_069 | Landschaftsgärtner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_068 | Landwirt EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_070 | Logistiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_071 | Lüftungsanlagenbauer EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_072 | Maler EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_073 | Malerpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_074 | Marketingfachmann EFZ | EFZ/EBA | Kaufmännisch | Berufliche Grundbildung |
| EDU_075 | Maurer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_076 | Mediamatiker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_077 | Medientechnologe EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_078 | Metallbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_079 | Metallbaukonstrukteur EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_080 | Metallbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_081 | Montage-Elektriker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_082 | Multimediaelektroniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_083 | Netzelektriker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_084 | Oberflächenbeschichter EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_085 | Ofenbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_086 | Pflästerer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_087 | Plattenleger EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_088 | Plattenlegerpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_089 | Polybauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_090 | Polymechaniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_091 | Raumausstatter EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_092 | Recyclist EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_093 | Sanitärinstallateur EFZ | EFZ/EBA | Gebäudetechnik | Berufliche Grundbildung |
| EDU_094 | Schreiner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_095 | Schreinerpraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_097 | Seilbahn-Mechatroniker EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_096 | Seilbahner EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_098 | Spengler EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_099 | Steinmetz EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_100 | Storenmontagepraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_101 | Storenmonteur EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_102 | Strassenbauer EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_103 | Strassenbaupraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_104 | Unterhaltspraktiker EBA | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_105 | Wohntextilgestalter EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_106 | Zeichner EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_107 | Zimmermann EFZ | EFZ/EBA | Handwerk | Berufliche Grundbildung |
| EDU_178 | Eidg. Dipl. Aussenhandelsfachmann FA | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_177 | Eidg. Dipl. Automatikfachmann FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_114 | Eidg. Dipl. Bau-Polier FA | Eidg. Dipl. | Bauführung | Berufsprüfung / Höhere Fachprüfung |
| EDU_109 | Eidg. Dipl. Baubiologe FA | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_110 | Eidg. Dipl. Bauführer Gebäudehülle FA | Eidg. Dipl. | Bauführung | Berufsprüfung / Höhere Fachprüfung |
| EDU_111 | Eidg. Dipl. Bauleiter Hochbau HFP | Eidg. Dipl. | Bauleitung | Berufsprüfung / Höhere Fachprüfung |
| EDU_112 | Eidg. Dipl. Bauleiter Tiefbau HFP | Eidg. Dipl. | Bauleitung | Berufsprüfung / Höhere Fachprüfung |
| EDU_113 | Eidg. Dipl. Baumeister HFP | Eidg. Dipl. | Bauführung | Berufsprüfung / Höhere Fachprüfung |
| EDU_115 | Eidg. Dipl. Bautenschutz-Fachmann FA | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_116 | Eidg. Dipl. Bodenlegermeister HFP | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_117 | Eidg. Dipl. Brandschutzexperte HFP | Eidg. Dipl. | Sicherheit | Berufsprüfung / Höhere Fachprüfung |
| EDU_118 | Eidg. Dipl. Brandschutzfachmann FA | Eidg. Dipl. | Sicherheit | Berufsprüfung / Höhere Fachprüfung |
| EDU_119 | Eidg. Dipl. Brunnenmeister FA | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_120 | Eidg. Dipl. Chefbodenleger FA | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_121 | Eidg. Dipl. Chefmonteur Heizung FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_122 | Eidg. Dipl. Chefmonteur Kälte FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_123 | Eidg. Dipl. Chefmonteur Lüftung FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_124 | Eidg. Dipl. Chefmonteur Sanitär FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_180 | Eidg. Dipl. Einkaufsfachmann HFP | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_179 | Eidg. Dipl. Einkaufsleiter HFP | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_125 | Eidg. Dipl. Einrichtungsplaner FA | Eidg. Dipl. | Architektur | Berufsprüfung / Höhere Fachprüfung |
| EDU_126 | Eidg. Dipl. Elektroinstallateur FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_127 | Eidg. Dipl. Elektroinstallation und Sicherheitsexperte HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_128 | Eidg. Dipl. Elektroplanungsexperte HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_129 | Eidg. Dipl. Elektroprojektleiter FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_130 | Eidg. Dipl. Elektroprojektleiter Installation und Sicherheit FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_131 | Eidg. Dipl. Elektroprojektleiter Planung FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_132 | Eidg. Dipl. Elektrosicherheitsberater | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_133 | Eidg. Dipl. Energieberater FA | Eidg. Dipl. | Energie & Umwelt | Berufsprüfung / Höhere Fachprüfung |
| EDU_134 | Eidg. Dipl. Experte Gesundes und Nachhaltiges Bauen HFP | Eidg. Dipl. | Nachhaltigkeit | Berufsprüfung / Höhere Fachprüfung |
| EDU_135 | Eidg. Dipl. Fachmann für Industrielackierung FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_136 | Eidg. Dipl. Fachmann für Komfortlüftungen FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_137 | Eidg. Dipl. Fachmann für Wärmesysteme FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_138 | Eidg. Dipl. Fachmann Systemdecken FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_181 | Eidg. Dipl. Fachmann Unternehmensführung KMU | Eidg. Dipl. | Management | Berufsprüfung / Höhere Fachprüfung |
| EDU_139 | Eidg. Dipl. Feuerungskontrolleur FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_140 | Eidg. Dipl. Gebäudehüllen-Meister HFP | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_141 | Eidg. Dipl. Gebäudereinigungs-Fachmann FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_142 | Eidg. Dipl. Geomatiktechniker FA | Eidg. Dipl. | Vermessung | Berufsprüfung / Höhere Fachprüfung |
| EDU_182 | Eidg. Dipl. Geschäftsführer Bau NDS HF | Eidg. Dipl. | Management | Berufsprüfung / Höhere Fachprüfung |
| EDU_143 | Eidg. Dipl. Handwerker in der Denkmalpflege FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_144 | Eidg. Dipl. Hausmeisterin HFP | Eidg. Dipl. | Facility Management | Berufsprüfung / Höhere Fachprüfung |
| EDU_145 | Eidg. Dipl. Hauswart FA | Eidg. Dipl. | Facility Management | Berufsprüfung / Höhere Fachprüfung |
| EDU_146 | Eidg. Dipl. Heizungsmeister HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_147 | Eidg. Dipl. Holzbau-Meister HFP | Eidg. Dipl. | Holzbau | Berufsprüfung / Höhere Fachprüfung |
| EDU_148 | Eidg. Dipl. Holzbau-Polier FA | Eidg. Dipl. | Holzbau | Berufsprüfung / Höhere Fachprüfung |
| EDU_149 | Eidg. Dipl. Holzbau-Vorarbeiter FA | Eidg. Dipl. | Holzbau | Berufsprüfung / Höhere Fachprüfung |
| EDU_150 | Eidg. Dipl. Holzfachmann FA | Eidg. Dipl. | Holzbau | Berufsprüfung / Höhere Fachprüfung |
| EDU_183 | Eidg. Dipl. Immobilienbewirtschafter FA | Eidg. Dipl. | Immobilien | Berufsprüfung / Höhere Fachprüfung |
| EDU_184 | Eidg. Dipl. Immobilienentwickler FA | Eidg. Dipl. | Immobilien | Berufsprüfung / Höhere Fachprüfung |
| EDU_185 | Eidg. Dipl. Immobilienschätzer FA | Eidg. Dipl. | Immobilien | Berufsprüfung / Höhere Fachprüfung |
| EDU_186 | Eidg. Dipl. Immobilientreuhänder HFP | Eidg. Dipl. | Immobilien | Berufsprüfung / Höhere Fachprüfung |
| EDU_187 | Eidg. Dipl. Immobilienvermarkter FA | Eidg. Dipl. | Immobilien | Berufsprüfung / Höhere Fachprüfung |
| EDU_151 | Eidg. Dipl. Innendekorateur HFP | Eidg. Dipl. | Architektur | Berufsprüfung / Höhere Fachprüfung |
| EDU_188 | Eidg. Dipl. Instandhaltungsfachmann FA | Eidg. Dipl. | Bau Spezialgebiet | Berufsprüfung / Höhere Fachprüfung |
| EDU_153 | Eidg. Dipl. Kaminfeger-Vorarbeiter FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_152 | Eidg. Dipl. Kaminfegermeister HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_154 | Eidg. Dipl. Lichtplaner FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_155 | Eidg. Dipl. Lüftungsbauer HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_156 | Eidg. Dipl. Malermeister HFP | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_189 | Eidg. Dipl. Marketingplaner FA | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_157 | Eidg. Dipl. Meister Wärmetechnikplanung HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_158 | Eidg. Dipl. Netzelektrikermeister HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_159 | Eidg. Dipl. Netzfachmann FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_160 | Eidg. Dipl. Plattenlegerchef FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_161 | Eidg. Dipl. Plattenlegermeister HFP | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_162 | Eidg. Dipl. Produktionsleiter Schreinerei FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_163 | Eidg. Dipl. Projektleiter Farbe FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_164 | Eidg. Dipl. Projektleiter Gebäudetechnik FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_165 | Eidg. Dipl. Projektleiter Schreinerei FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_166 | Eidg. Dipl. Projektleiter Sicherheitssysteme FA | Eidg. Dipl. | Sicherheit | Berufsprüfung / Höhere Fachprüfung |
| EDU_167 | Eidg. Dipl. Projektleiter Solarmontage FA | Eidg. Dipl. | Energie & Umwelt | Berufsprüfung / Höhere Fachprüfung |
| EDU_168 | Eidg. Dipl. Projektleiter Sonnenschutz FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_190 | Eidg. Dipl. Prozessfachmann FA | Eidg. Dipl. | Management | Berufsprüfung / Höhere Fachprüfung |
| EDU_169 | Eidg. Dipl. Rohrnetzmonteur FA | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_170 | Eidg. Dipl. Sanitärmeister HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_171 | Eidg. Dipl. Sanitärplaner HFP | Eidg. Dipl. | Gebäudetechnik | Berufsprüfung / Höhere Fachprüfung |
| EDU_172 | Eidg. Dipl. Schreinermeister HFP | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_173 | Eidg. Dipl. Sicherheitsspezialist FA | Eidg. Dipl. | Sicherheit | Berufsprüfung / Höhere Fachprüfung |
| EDU_174 | Eidg. Dipl. Spenglermeister HFP | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_175 | Eidg. Dipl. Spenglerpolier FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_191 | Eidg. Dipl. Technischer Kaufmann | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_192 | Eidg. Dipl. Verkaufsfachmann FA | Eidg. Dipl. | Kaufmännisch | Berufsprüfung / Höhere Fachprüfung |
| EDU_193 | Eidg. Dipl. Vorarbeiter FA | Eidg. Dipl. | Bauführung | Berufsprüfung / Höhere Fachprüfung |
| EDU_176 | Eidg. Dipl. Wohntextilgestalter FA | Eidg. Dipl. | Handwerk | Berufsprüfung / Höhere Fachprüfung |
| EDU_499 | EMBA | EMBA | Management | Weiterbildung |
| EDU_309 | Architektur Bachelor ETH | ETH Bachelor | Architektur | ETH / Universität |
| EDU_311 | Bauingenieurwesen Bachelor ETH | ETH Bachelor | Bauingenieurwesen | ETH / Universität |
| EDU_314 | Biotechnologie Bachelor ETH | ETH Bachelor | Natur & Umwelt | ETH / Universität |
| EDU_317 | Elektrotechnik und Informationstechnologie Bachelor/Master | ETH Bachelor | Gebäudetechnik | ETH / Universität |
| EDU_318 | Geografie Bachelor ETH | ETH Bachelor | Vermessung | ETH / Universität |
| EDU_320 | Geomatik Bachelor ETH | ETH Bachelor | Vermessung | ETH / Universität |
| EDU_322 | Geoumweltwissenschaft Bachelor ETH | ETH Bachelor | Natur & Umwelt | ETH / Universität |
| EDU_328 | Umweltingenieurwissenschaften Bachelor ETH | ETH Bachelor | Natur & Umwelt | ETH / Universität |
| EDU_310 | Architektur Master ETH | ETH Master | Architektur | ETH / Universität |
| EDU_312 | Bauingenieurwesen Master ETH | ETH Master | Bauingenieurwesen | ETH / Universität |
| EDU_315 | Biotechnologie Master ETH | ETH Master | Natur & Umwelt | ETH / Universität |
| EDU_319 | Geografie Master ETH | ETH Master | Vermessung | ETH / Universität |
| EDU_321 | Geomatik Master ETH | ETH Master | Vermessung | ETH / Universität |
| EDU_329 | Umweltingenieurwissenschaften Master ETH | ETH Master | Natur & Umwelt | ETH / Universität |
| EDU_330 | Wirtschaftsingenieurwesen Master ETH | ETH Master | Wirtschaft | ETH / Universität |
| EDU_257 | Agronomie Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_258 | Architektur Bachelor FH | FH Bachelor | Architektur | Fachhochschule |
| EDU_293 | Aviatik Bachelor FH | FH Bachelor | Ingenieurwesen | Fachhochschule |
| EDU_259 | Bauingenieurwesen Bachelor FH | FH Bachelor | Bauingenieurwesen | Fachhochschule |
| EDU_260 | Betriebsökonomie Bachelor FH | FH Bachelor | Wirtschaft | Fachhochschule |
| EDU_261 | Biotechnologie Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_262 | Building Technology Bachelor FH | FH Bachelor | Gebäudetechnik | Fachhochschule |
| EDU_263 | Business Administration Bachelor FH | FH Bachelor | Wirtschaft | Fachhochschule |
| EDU_264 | Business Administration Bachelor FH Major Immobilien | FH Bachelor | Immobilien | Fachhochschule |
| EDU_265 | Digital Construction Bachelor FH | FH Bachelor | Digitalisierung Bau | Fachhochschule |
| EDU_266 | Digital Engineering Bachelor FH | FH Bachelor | Digitalisierung Bau | Fachhochschule |
| EDU_267 | Elektroengineering Bachelor FH | FH Bachelor | Gebäudetechnik | Fachhochschule |
| EDU_268 | Energie- und Umwelttechnik Bachelor FH | FH Bachelor | Energie & Umwelt | Fachhochschule |
| EDU_269 | Engineering Bachelor FH | FH Bachelor | Ingenieurwesen | Fachhochschule |
| EDU_270 | Erneuerbare Energien und Umwelttechnik Bachelor FH | FH Bachelor | Energie & Umwelt | Fachhochschule |
| EDU_271 | Facility Management Bachelor FH | FH Bachelor | Facility Management | Fachhochschule |
| EDU_272 | Gebäude-Elektroengineering (GEE) Bachelor FH | FH Bachelor | Gebäudetechnik | Fachhochschule |
| EDU_273 | Gebäudetechnik Bachelor FH | FH Bachelor | Gebäudetechnik | Fachhochschule |
| EDU_274 | Geomatik Bachelor FH | FH Bachelor | Vermessung | Fachhochschule |
| EDU_275 | Heizung-Lüftung-Klima-Sanitär Bachelor FH | FH Bachelor | Gebäudetechnik | Fachhochschule |
| EDU_276 | Holztechnik Bachelor FH | FH Bachelor | Holzbau | Fachhochschule |
| EDU_277 | Innenarchitektur Bachelor FH | FH Bachelor | Architektur | Fachhochschule |
| EDU_278 | Landschaftsarchitektur Bachelor FH | FH Bachelor | Landschaft & Raum | Fachhochschule |
| EDU_279 | Life Technologies Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_280 | Maschinenbau Bachelor FH | FH Bachelor | Ingenieurwesen | Fachhochschule |
| EDU_281 | Medizintechnik Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_282 | Mobility, Data Science and Economics Bachelor FH | FH Bachelor | Mobilität | Fachhochschule |
| EDU_283 | Raumbezogene Ingenieurwissenschaften Bachelor | FH Bachelor | Landschaft & Raum | Fachhochschule |
| EDU_285 | Rechtswissenschaft Bachelor FH | FH Bachelor | Recht | Fachhochschule |
| EDU_286 | Stadt-, Verkehrs- und Raumplanung Bachelor FH | FH Bachelor | Raumplanung | Fachhochschule |
| EDU_287 | Umweltingenieurwesen Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_288 | Umweltökonomie und -management Bachelor FH | FH Bachelor | Natur & Umwelt | Fachhochschule |
| EDU_289 | Verkehrssysteme Bachelor FH | FH Bachelor | Mobilität | Fachhochschule |
| EDU_291 | Wirtschaftsinformatik Bachelor FH | FH Bachelor | Wirtschaft | Fachhochschule |
| EDU_292 | Wirtschaftsingenieurwesen Bachelor FH | FH Bachelor | Wirtschaft | Fachhochschule |
| EDU_294 | Architektur Master FH | FH Master | Architektur | Fachhochschule |
| EDU_296 | Banking & Finance Master FH | FH Master | Wirtschaft | Fachhochschule |
| EDU_295 | Bauingenieurwesen Master FH | FH Master | Bauingenieurwesen | Fachhochschule |
| EDU_297 | Business Administration Master FH | FH Master | Wirtschaft | Fachhochschule |
| EDU_298 | Digital Construction Master FH | FH Master | Digitalisierung Bau | Fachhochschule |
| EDU_299 | Elektroengineering Master FH | FH Master | Gebäudetechnik | Fachhochschule |
| EDU_300 | Energie- und Umwelttechnik Master FH | FH Master | Energie & Umwelt | Fachhochschule |
| EDU_301 | Engineering Master FH | FH Master | Ingenieurwesen | Fachhochschule |
| EDU_302 | Geomatik Master FH | FH Master | Vermessung | Fachhochschule |
| EDU_303 | Holztechnik Master FH | FH Master | Holzbau | Fachhochschule |
| EDU_304 | Maschinenbau Master FH | FH Master | Ingenieurwesen | Fachhochschule |
| EDU_305 | Raumbezogene Ingenieurwissenschaften Master | FH Master | Landschaft & Raum | Fachhochschule |
| EDU_306 | Raumentwicklung und Infrastruktursysteme Master | FH Master | Raumplanung | Fachhochschule |
| EDU_284 | Real Estate Master FH | FH Master | Immobilien | Fachhochschule |
| EDU_307 | Rechtswissenschaft Master FH | FH Master | Recht | Fachhochschule |
| EDU_290 | Virtual Design and Construction (VDC) Master FH | FH Master | Digitalisierung Bau | Fachhochschule |
| EDU_308 | Wirtschaftsingenieurwesen Master FH | FH Master | Wirtschaft | Fachhochschule |
| EDU_202 | Dipl. Techniker HF AgroTechnik | HF | Natur & Umwelt | Höhere Fachschule |
| EDU_203 | Dipl. Techniker HF Automation | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_204 | Dipl. Techniker HF Bauführung | HF | Bauführung | Höhere Fachschule |
| EDU_207 | Dipl. Techniker HF Bauführung Garten- und Landschaftsbau | HF | Bauführung | Höhere Fachschule |
| EDU_205 | Dipl. Techniker HF Bauführung Hochbau | HF | Bauführung | Höhere Fachschule |
| EDU_206 | Dipl. Techniker HF Bauführung Verkehrswegbau | HF | Bauführung | Höhere Fachschule |
| EDU_208 | Dipl. Techniker HF Bauplanung | HF | Architektur | Höhere Fachschule |
| EDU_209 | Dipl. Techniker HF Bauplanung Architektur | HF | Architektur | Höhere Fachschule |
| EDU_210 | Dipl. Techniker HF Bauplanung Ingenieurbau | HF | Bauingenieurwesen | Höhere Fachschule |
| EDU_211 | Dipl. Techniker HF Bauplanung Innenarchitektur | HF | Architektur | Höhere Fachschule |
| EDU_230 | Dipl. Techniker HF Betriebliches Management | HF | Management | Höhere Fachschule |
| EDU_212 | Dipl. Techniker HF Business Processmanagement | HF | Management | Höhere Fachschule |
| EDU_229 | Dipl. Techniker HF Digitale Projektabwicklung | HF | Digitalisierung Bau | Höhere Fachschule |
| EDU_213 | Dipl. Techniker HF Elektrotechnik | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_214 | Dipl. Techniker HF Elektrotechnik Vertiefung | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_215 | Dipl. Techniker HF Energie und Umwelt | HF | Energie & Umwelt | Höhere Fachschule |
| EDU_240 | Dipl. Techniker HF Energietechnik | HF | Energie & Umwelt | Höhere Fachschule |
| EDU_223 | Dipl. Techniker HF Gebäudeinformatik / Building Automation | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_216 | Dipl. Techniker HF Gebäudetechnik | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_221 | Dipl. Techniker HF Gebäudetechnik Vertiefung Elektro | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_222 | Dipl. Techniker HF Gebäudetechnik Vertiefung GA | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_217 | Dipl. Techniker HF Gebäudetechnik Vertiefung Heizung | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_220 | Dipl. Techniker HF Gebäudetechnik Vertiefung Kälte | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_218 | Dipl. Techniker HF Gebäudetechnik Vertiefung Lüftung | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_219 | Dipl. Techniker HF Gebäudetechnik Vertiefung Sanitär | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_224 | Dipl. Techniker HF Holztechnik | HF | Holzbau | Höhere Fachschule |
| EDU_225 | Dipl. Techniker HF Holztechnik Vertiefung Schreinerei | HF | Holzbau | Höhere Fachschule |
| EDU_226 | Dipl. Techniker HF Informatik | HF | Digitalisierung Bau | Höhere Fachschule |
| EDU_227 | Dipl. Techniker HF Innenausbau und Produktion | HF | Architektur | Höhere Fachschule |
| EDU_228 | Dipl. Techniker HF Maschinenbau | HF | Ingenieurwesen | Höhere Fachschule |
| EDU_231 | Dipl. Techniker HF Software Engineering | HF | Digitalisierung Bau | Höhere Fachschule |
| EDU_232 | Dipl. Techniker HF Systemtechnik | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_233 | Dipl. Techniker HF Systemtechnik Vertiefung Automation | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_235 | Dipl. Techniker HF Systemtechnik Vertiefung Elektronik | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_234 | Dipl. Techniker HF Systemtechnik Vertiefung Informatik | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_236 | Dipl. Techniker HF Telekommunikation | HF | Gebäudetechnik | Höhere Fachschule |
| EDU_237 | Dipl. Techniker HF Unternehmensprozesse | HF | Management | Höhere Fachschule |
| EDU_238 | Dipl. Techniker HF Unternehmensprozesse für Baugewerbe | HF | Management | Höhere Fachschule |
| EDU_239 | Dipl. Techniker HF Unternehmensprozesse Logistik | HF | Management | Höhere Fachschule |
| EDU_241 | Dipl. Wirtschaftsinformatiker HF | HF | Wirtschaft | Höhere Fachschule |
| EDU_200 | Geografie Bachelor HF | HF | Vermessung | Höhere Fachschule |
| EDU_201 | Geografie Master HF | HF | Vermessung | Höhere Fachschule |
| EDU_199 | Raumplanung, Städtebau & Architektur Bachelor HF | HF | Raumplanung | Höhere Fachschule |
| EDU_244 | Dipl. Bankmanager NDS HF | HF NDS | Wirtschaft | Höhere Fachschule |
| EDU_243 | Dipl. Baubetriebsmanagement NDS HF | HF NDS | Bauführung | Höhere Fachschule |
| EDU_242 | Dipl. Bauprojekt- und Immobilienmanager NDS HF | HF NDS | Immobilien | Höhere Fachschule |
| EDU_245 | Dipl. Betriebsökonom NDS HF | HF NDS | Wirtschaft | Höhere Fachschule |
| EDU_246 | Dipl. Betriebswirtschafter NDS HF | HF NDS | Wirtschaft | Höhere Fachschule |
| EDU_247 | Dipl. Dienstleistungsmanager NDS FH | HF NDS | Management | Fachhochschule |
| EDU_248 | Dipl. Energiemanager NDS HF | HF NDS | Energie & Umwelt | Höhere Fachschule |
| EDU_249 | Dipl. Energieplaner NDS HF | HF NDS | Energie & Umwelt | Höhere Fachschule |
| EDU_250 | Dipl. Gebäudeinformatiker NDS FH | HF NDS | Gebäudetechnik | Fachhochschule |
| EDU_251 | Dipl. Geschäftsführer Bau NDS HF | HF NDS | Management | Höhere Fachschule |
| EDU_253 | Dipl. Projektmanagement und Führung NDS HF | HF NDS | Management | Höhere Fachschule |
| EDU_252 | Dipl. Projektmanager NDS HF | HF NDS | Management | Höhere Fachschule |
| EDU_254 | Dipl. Real Estate Manager NDS FH | HF NDS | Immobilien | Fachhochschule |
| EDU_255 | Dipl. Unternehmensführung NDS HF | HF NDS | Management | Höhere Fachschule |
| EDU_256 | Dipl. Wirtschaftsingenieur NDS FH | HF NDS | Wirtschaft | Fachhochschule |
| EDU_458 | MAS Architecture and Digital Fabrication | MAS | Architektur | Weiterbildung |
| EDU_459 | MAS Architecture, Real Estate, Construction | MAS | Architektur | Weiterbildung |
| EDU_464 | MAS Banking & Finance FH | MAS | Wirtschaft | Weiterbildung |
| EDU_460 | MAS Bauleitung | MAS | Bauleitung | Weiterbildung |
| EDU_461 | MAS Baumanagement | MAS | Management | Weiterbildung |
| EDU_462 | MAS Bauökonomie | MAS | Bauökonomie | Weiterbildung |
| EDU_463 | MAS Bauphysik | MAS | Bauphysik | Weiterbildung |
| EDU_465 | MAS Collective Housing | MAS | Architektur | Weiterbildung |
| EDU_466 | MAS Denkmalpflege und Konstruktionsgeschichte | MAS | Architektur | Weiterbildung |
| EDU_467 | MAS Digitale Transformation | MAS | Digitalisierung Bau | Weiterbildung |
| EDU_468 | MAS Digitales Bauen | MAS | Digitalisierung Bau | Weiterbildung |
| EDU_469 | MAS Energie am Bau | MAS | Energie & Umwelt | Weiterbildung |
| EDU_470 | MAS Energie und Ressourceneffizienz | MAS | Energie & Umwelt | Weiterbildung |
| EDU_471 | MAS Energieingenieur Gebäude | MAS | Energie & Umwelt | Weiterbildung |
| EDU_472 | MAS Energiesysteme | MAS | Energie & Umwelt | Weiterbildung |
| EDU_473 | MAS Energiewirtschaft | MAS | Energie & Umwelt | Weiterbildung |
| EDU_474 | MAS Fire Safety Engineering | MAS | Sicherheit | Weiterbildung |
| EDU_475 | MAS Gemeinde-, Stadt- und Regionalentwicklung | MAS | Raumplanung | Weiterbildung |
| EDU_477 | MAS Gesamtprojektleitung Bau | MAS | Management | Weiterbildung |
| EDU_478 | MAS Gesamtprojektleitung Bau ETH | MAS | Management | Weiterbildung |
| EDU_476 | MAS Geschichte und Theorie der Architektur | MAS | Architektur | Weiterbildung |
| EDU_479 | MAS Holzbau | MAS | Holzbau | Weiterbildung |
| EDU_480 | MAS Housing | MAS | Architektur | Weiterbildung |
| EDU_481 | MAS Immobilienmanagement | MAS | Immobilien | Weiterbildung |
| EDU_482 | MAS Information & Cyber Security | MAS | Digitalisierung Bau | Weiterbildung |
| EDU_483 | MAS Information Engineering | MAS | Management | Weiterbildung |
| EDU_498 | MAS Infrastruktur und Verkehr BFH | MAS | Bauingenieurwesen | Weiterbildung |
| EDU_484 | MAS Leadership und Management | MAS | Management | Weiterbildung |
| EDU_485 | MAS Management, Technologie und Wirtschaft | MAS | Management | Weiterbildung |
| EDU_486 | MAS Management, Technology and Economics | MAS | Management | Weiterbildung |
| EDU_487 | MAS Nachhaltiges Bauen | MAS | Nachhaltigkeit | Weiterbildung |
| EDU_488 | MAS Projektmanagement Bau | MAS | Projektmanagement | Weiterbildung |
| EDU_489 | MAS Public Management | MAS | Management | Weiterbildung |
| EDU_490 | MAS Raumentwicklung | MAS | Raumplanung | Weiterbildung |
| EDU_491 | MAS Raumplanung ETH | MAS | Raumplanung | Weiterbildung |
| EDU_492 | MAS Real Estate Management | MAS | Immobilien | Weiterbildung |
| EDU_493 | MAS Sustainable Water Resources | MAS | Natur & Umwelt | Weiterbildung |
| EDU_494 | MAS Szenografie | MAS | Architektur | Weiterbildung |
| EDU_495 | MAS Urban and Territorial Design | MAS | Raumplanung | Weiterbildung |
| EDU_496 | MAS Urban Design | MAS | Raumplanung | Weiterbildung |
| EDU_497 | MAS Wasserbauingenieur | MAS | Bauingenieurwesen | Weiterbildung |
| EDU_500 | MBA | MBA | Management | Weiterbildung |
| EDU_327 | Betriebswirtschaft Bachelor UNI | Uni Bachelor | Wirtschaft | ETH / Universität |
| EDU_323 | Molekularbiologie Bachelor Universität | Uni Bachelor | Natur & Umwelt | ETH / Universität |
| EDU_325 | Rechtswissenschaft Bachelor Uni | Uni Bachelor | Recht | ETH / Universität |
| EDU_326 | Rechtswissenschaft Master Uni | Uni Master | Recht | ETH / Universität |
| EDU_501 | Vorbereitungskurs Eidg. Dipl Bauleiter HFP | Vorbereitungskurs | Bauleitung | Weiterbildung |

---

## 4. Cluster (dim_cluster)

| ID | Name | Typ | Parent |
|-----|------|-----|--------|
| SC_049 | Akquisition (Projekt, Kapital, Land) | Architecture | CL_010 |
| SC_048 | Areal-, Immobilien-, + Projektentwicklung | Architecture | CL_010 |
| SC_051 | Ausführungs- und Detailplanung | Architecture | CL_011 |
| SC_052 | Baubewilligungen und Behörde | Architecture | CL_011 |
| CL_014 | Bauherrenberatung | Architecture |  |
| SC_061 | Bauherrenberatung + Consulting | Architecture | CL_014 |
| SC_062 | Bauherrenvertretung + Eigentümer | Architecture | CL_014 |
| CL_013 | Bauökonomie | Architecture |  |
| SC_060 | Bauökonomie und Baukostenplanung | Architecture | CL_013 |
| SC_053 | Devisierungen, Ausschreibungen | Architecture | CL_012 |
| SC_063 | Digitalisierung | Architecture | CL_015 |
| SC_064 | Einkauf / Beschaffung | Architecture | CL_015 |
| CL_010 | Entwicklung / Akquisition | Architecture |  |
| SC_050 | Entwurf- und Wettbewerb | Architecture | CL_011 |
| SC_059 | Gesamte Realisierung | Architecture | CL_012 |
| SC_054 | Innenausbau, Ladenbau und Interior | Architecture | CL_012 |
| SC_056 | Käuferbetreuung, Garantie & Mängel | Architecture | CL_012 |
| SC_065 | Lean Management | Architecture | CL_015 |
| SC_057 | Neubau | Architecture | CL_012 |
| CL_011 | Planung / Projektierung | Architecture |  |
| SC_066 | Produktvertrieb | Architecture | CL_015 |
| CL_012 | Realisierung | Architecture |  |
| SC_055 | Rohbau, Fassadenbau | Architecture | CL_012 |
| CL_015 | Spezialteam | Architecture |  |
| SC_058 | Umbau, Strangsanierung, Denkmalschutz | Architecture | CL_012 |
| SC_006 | Brand- + Blitzschutz | Building Technology | CL_001 |
| SC_015 | E-Mobility | Building Technology | CL_004 |
| SC_008 | Elektro | Building Technology | CL_002 |
| CL_002 | Elektro + GA | Building Technology |  |
| CL_004 | Energie | Building Technology |  |
| SC_011 | Energie | Building Technology | CL_004 |
| SC_007 | Fernwärme / Fernkälte | Building Technology | CL_001 |
| SC_009 | Gebäudeautomation & MSRL | Building Technology | CL_002 |
| SC_001 | Heizung | Building Technology | CL_001 |
| CL_001 | HLKS | Building Technology |  |
| SC_004 | Kälte | Building Technology | CL_001 |
| SC_003 | Klima | Building Technology | CL_001 |
| SC_014 | Kraftwerke | Building Technology | CL_004 |
| SC_002 | Lüftung | Building Technology | CL_001 |
| SC_012 | Netzbau Starkstrom | Building Technology | CL_004 |
| SC_005 | Sanitär | Building Technology | CL_001 |
| CL_003 | SIBE | Building Technology |  |
| SC_010 | Sicherheit- und Risiko | Building Technology | CL_003 |
| SC_013 | Solar / PV | Building Technology | CL_004 |
| SC_037 | Abwasser / ARA + Kanalisationsbau | Civil Engineering | CL_007 |
| SC_017 | Bahn / Fahrbahn | Civil Engineering | CL_005 |
| SC_030 | Bauphysik / Akustik | Civil Engineering | CL_006 |
| SC_027 | Bautenschutz & Bauwerksinstandsetzung | Civil Engineering | CL_006 |
| SC_042 | Bodenschutz & Nachhaltigkeit | Civil Engineering | CL_009 |
| SC_025 | Brückenbau | Civil Engineering | CL_006 |
| SC_041 | Erd- & Grundbau | Civil Engineering | CL_009 |
| SC_044 | Flora / Fauna / Forst | Civil Engineering | CL_009 |
| SC_032 | Fluss-/ Seebau | Civil Engineering | CL_007 |
| SC_038 | Geomatik + Vermessung | Civil Engineering | CL_008 |
| SC_040 | Geotechnik | Civil Engineering | CL_009 |
| SC_035 | GEP / Entwässerung | Civil Engineering | CL_007 |
| CL_009 | Grundbau, Geotechnik & Umwelt | Civil Engineering |  |
| SC_033 | Hochwasser- und Grundwasserschutz | Civil Engineering | CL_007 |
| SC_024 | Holz & Massivbau | Civil Engineering | CL_006 |
| SC_036 | Hydrologie | Civil Engineering | CL_007 |
| CL_005 | Infrastruktur | Civil Engineering |  |
| CL_006 | Kunstbau + Hochbau | Civil Engineering |  |
| SC_045 | Lärmschutz & Luftreinhaltung | Civil Engineering | CL_009 |
| SC_020 | Mobility | Civil Engineering | CL_005 |
| SC_021 | Netzbau (konstruktiv) | Civil Engineering | CL_005 |
| SC_019 | Raumplanung / Verkehrsplanung | Civil Engineering | CL_005 |
| SC_046 | Recycling, Altlasten & Entsorgung | Civil Engineering | CL_009 |
| SC_031 | Rückbau | Civil Engineering | CL_006 |
| SC_028 | Schalungsbau | Civil Engineering | CL_006 |
| SC_047 | Spezialtiefbau | Civil Engineering | CL_009 |
| SC_026 | Stahl-, Fassadenbau & Eventbau | Civil Engineering | CL_006 |
| SC_029 | Statik, Tragwerksplanung & Erdbeben | Civil Engineering | CL_006 |
| SC_018 | Strassenbau | Civil Engineering | CL_005 |
| SC_023 | Stützbauten | Civil Engineering | CL_006 |
| SC_022 | Tunnelbau & Untertagbau | Civil Engineering | CL_006 |
| SC_043 | UBB / UVB | Civil Engineering | CL_009 |
| SC_039 | Verkehrssicherheit | Civil Engineering | CL_008 |
| CL_008 | Vermessung | Civil Engineering |  |
| CL_007 | Wasserbau | Civil Engineering |  |
| SC_034 | Wasserkraftwerke | Civil Engineering | CL_007 |
| SC_016 | Werkleitungen | Civil Engineering | CL_005 |
| SC_067 | Asset + Portfoliomanager | Real Estate Management | CL_016 |
| SC_069 | Asset Management | Real Estate Management | CL_016 |
| CL_018 | Bautreuhand | Real Estate Management |  |
| CL_016 | Bewirtschaftung, Asset und Portfolio | Real Estate Management |  |
| CL_019 | Facility Management | Real Estate Management |  |
| SC_078 | Facility Management & Hauswartung | Real Estate Management | CL_019 |
| SC_074 | Immobilienbewertung | Real Estate Management | CL_017 |
| SC_068 | Immobilienbewirtschaftung | Real Estate Management | CL_016 |
| SC_075 | Immobilienbuchhaltung | Real Estate Management | CL_018 |
| SC_073 | Immobilienschätzung | Real Estate Management | CL_017 |
| SC_077 | Immobilientreuhand | Real Estate Management | CL_018 |
| SC_072 | Immobilienvermarktung | Real Estate Management | CL_017 |
| SC_071 | Investment | Real Estate Management | CL_016 |
| SC_070 | Portfolio Management | Real Estate Management | CL_016 |
| SC_076 | Steuerspezialist Real Estate | Real Estate Management | CL_018 |
| CL_017 | Vermarktung + Schätzung | Real Estate Management |  |

---

## 5. Focus / Spezialisierung (dim_focus)

| ID | Name | Kategorie | Parent |
|-----|------|----------|--------|
| foc_172 | Forschung | Allgemein |  |
| foc_171 | Real Estate | Allgemein |  |
| foc_170 | Technik | Allgemein |  |
| foc_220 | Innenausbau | Architektur |  |
| foc_206 | Ladenbau | Architektur |  |
| foc_207 | Modernisierung | Architektur |  |
| foc_208 | Neubau | Architektur |  |
| foc_200 | Revitalisierung | Architektur |  |
| foc_210 | Rückbau | Architektur |  |
| foc_209 | Umbau | Architektur |  |
| foc_006 | AVOR | Bauführung |  |
| foc_085 | Bauberatung | Bauherrenberatung |  |
| foc_086 | Bauherrenvertretung | Bauherrenberatung | foc_085 |
| foc_219 | Ausführung | Bauleitung |  |
| foc_213 | AVOR | Bauleitung |  |
| foc_217 | Realisierung | Bauleitung |  |
| foc_229 | Bauberatung | Beratung |  |
| foc_230 | Bauherrenvertretung | Beratung |  |
| foc_151 | Bauunterhalt | Betrieb & FM |  |
| foc_148 | Facility Management | Betrieb & FM |  |
| foc_150 | Move & Infrastrukturservice | Betrieb & FM | foc_148 |
| foc_152 | Service | Betrieb & FM |  |
| foc_149 | Technisches Gebäude Management | Betrieb & FM | foc_148 |
| foc_238 | BIM Präsentation | BIM |  |
| foc_102 | BIM | Digitalisierung |  |
| foc_103 | BIM Präsentation | Digitalisierung | foc_102 |
| foc_105 | Data & Analysis | Digitalisierung |  |
| foc_106 | Datenmanagement | Digitalisierung | foc_105 |
| foc_108 | Digital Strategy | Digitalisierung |  |
| foc_114 | Digital Twin | Digitalisierung |  |
| foc_112 | Digitale Logistik im Bau | Digitalisierung |  |
| foc_107 | Enterprise Mobility | Digitalisierung |  |
| foc_110 | ERP | Digitalisierung |  |
| foc_109 | ICT | Digitalisierung |  |
| foc_104 | Issue-Management | Digitalisierung |  |
| foc_111 | Programmieren | Digitalisierung |  |
| foc_113 | Smart Building / IoT | Digitalisierung |  |
| foc_153 | Einkauf | Einkauf & Beschaffung |  |
| foc_242 | Energiemesssysteme | Energie |  |
| foc_243 | New Energy | Energie |  |
| foc_051 | EKG | Energie & Umwelt |  |
| foc_042 | eMobility | Energie & Umwelt |  |
| foc_047 | Energieanlagen | Energie & Umwelt |  |
| foc_050 | Energiewirtschaft | Energie & Umwelt |  |
| foc_049 | Energy und Performance | Energie & Umwelt |  |
| foc_053 | Erdwärmenutzung | Energie & Umwelt |  |
| foc_043 | Erneuerbare Energien | Energie & Umwelt |  |
| foc_046 | Fernwärme | Energie & Umwelt |  |
| foc_055 | Fernwärmenetz Planung | Energie & Umwelt | foc_046 |
| foc_044 | Multi Energiesysteme | Energie & Umwelt |  |
| foc_045 | Neue Energien | Energie & Umwelt |  |
| foc_040 | Photovoltaik | Energie & Umwelt |  |
| foc_052 | Sektorkopplung | Energie & Umwelt |  |
| foc_048 | Smart Energy | Energie & Umwelt |  |
| foc_041 | Solar | Energie & Umwelt | foc_040 |
| foc_054 | Wärmepumpenplanung | Energie & Umwelt |  |
| foc_129 | Disziplinarische Führung | Führung |  |
| foc_130 | Fachliche Führung | Führung |  |
| foc_035 | Akustik | Gebäudetechnik |  |
| foc_025 | Anlagenbau | Gebäudetechnik |  |
| foc_024 | Blitzschutz | Gebäudetechnik |  |
| foc_023 | Brandschutz | Gebäudetechnik |  |
| foc_014 | Elektro | Gebäudetechnik |  |
| foc_037 | Elektroabnahmen | Gebäudetechnik | foc_014 |
| foc_027 | Elektroenergieverteilung | Gebäudetechnik | foc_014 |
| foc_029 | Fahrleitungen | Gebäudetechnik |  |
| foc_030 | Fahrstrom | Gebäudetechnik |  |
| foc_018 | Gebäudeautomation | Gebäudetechnik |  |
| foc_039 | Grossbatterie | Gebäudetechnik |  |
| foc_009 | Heizung | Gebäudetechnik | foc_008 |
| foc_008 | HLKS | Gebäudetechnik |  |
| foc_019 | Hochspannung | Gebäudetechnik | foc_014 |
| foc_034 | Hydraulik | Gebäudetechnik |  |
| foc_012 | Kälte | Gebäudetechnik | foc_008 |
| foc_011 | Klima | Gebäudetechnik | foc_008 |
| foc_016 | KNX | Gebäudetechnik |  |
| foc_214 | KNX | Gebäudetechnik |  |
| foc_032 | Kommunikation- und Leittechnik | Gebäudetechnik |  |
| foc_036 | Licht | Gebäudetechnik |  |
| foc_010 | Lüftung | Gebäudetechnik | foc_008 |
| foc_020 | Mittelspannung | Gebäudetechnik | foc_014 |
| foc_203 | MSRL | Gebäudetechnik |  |
| foc_015 | MSRL | Gebäudetechnik |  |
| foc_028 | Netze | Gebäudetechnik |  |
| foc_021 | Niederspannung | Gebäudetechnik | foc_014 |
| foc_026 | Rauch und Luft | Gebäudetechnik |  |
| foc_013 | Sanitär | Gebäudetechnik | foc_008 |
| foc_038 | Service | Gebäudetechnik |  |
| foc_022 | Sprinkler | Gebäudetechnik |  |
| foc_017 | SPS | Gebäudetechnik |  |
| foc_204 | SPS | Gebäudetechnik |  |
| foc_031 | Transformatoren und Energiekabel | Gebäudetechnik |  |
| foc_033 | Wärmedämmung | Gebäudetechnik |  |
| foc_134 | Arealprojekte | Immobilien | foc_132 |
| foc_145 | Due Diligence | Immobilien |  |
| foc_136 | Eigentumswohnungen | Immobilien |  |
| foc_132 | Entwicklung | Immobilien |  |
| foc_138 | Geschäftsflächen | Immobilien |  |
| foc_137 | Gewerbeflächen | Immobilien |  |
| foc_131 | Immobilien | Immobilien |  |
| foc_140 | Immobilienökonomie | Immobilien |  |
| foc_144 | Käuferbetreuung | Immobilien |  |
| foc_146 | Kredit | Immobilien |  |
| foc_139 | Life Cycle Management | Immobilien |  |
| foc_135 | Mietwohnungen | Immobilien |  |
| foc_141 | Mixed Reality und Artificial Intelligence | Immobilien |  |
| foc_143 | Objektmanagement | Immobilien |  |
| foc_147 | Proptech | Immobilien |  |
| foc_133 | Standortentwicklung | Immobilien | foc_132 |
| foc_142 | Vermarktung | Immobilien |  |
| foc_082 | Innenausbau | Innenausbau |  |
| foc_083 | Ladenbau | Innenausbau | foc_082 |
| foc_084 | Messebau | Innenausbau | foc_082 |
| foc_004 | Baugrunduntersuchung | Konstruktion |  |
| foc_007 | Bauphysik | Konstruktion |  |
| foc_001 | Bohrtechnik | Konstruktion |  |
| foc_168 | Entwässerung | Konstruktion |  |
| foc_003 | Eventbau | Konstruktion |  |
| foc_069 | Flussbau | Konstruktion | foc_068 |
| foc_215 | Hochbau | Konstruktion |  |
| foc_005 | Sekundärtechnik | Konstruktion |  |
| foc_201 | Spezialbeton | Konstruktion |  |
| foc_248 | Stahlbau | Konstruktion |  |
| foc_249 | Statik | Konstruktion |  |
| foc_002 | Temporärbau | Konstruktion |  |
| foc_216 | Tiefbau | Konstruktion |  |
| foc_251 | Tragwerksplanung | Konstruktion |  |
| foc_167 | Trasseebau | Konstruktion |  |
| foc_070 | Wasser und Abwasser | Konstruktion | foc_068 |
| foc_068 | Wasserbau | Konstruktion |  |
| foc_223 | Ausschreibung | Kostenmanagement |  |
| foc_221 | Kalkulation | Kostenmanagement |  |
| foc_128 | Beratung | Management |  |
| foc_125 | Controlling | Management |  |
| foc_211 | Produkt Management | Management |  |
| foc_127 | Prozessberatung | Management |  |
| foc_126 | Qualitätssicherung | Management |  |
| foc_123 | Strategie | Management |  |
| foc_222 | Teamleitung | Management |  |
| foc_124 | Transformation | Management |  |
| foc_212 | Vertrieb | Management |  |
| foc_116 | ESG | Nachhaltigkeit | foc_115 |
| foc_118 | Kreislaufwirtschaft | Nachhaltigkeit | foc_115 |
| foc_117 | MINERGIE / SNBS | Nachhaltigkeit | foc_115 |
| foc_115 | Nachhaltigkeit | Nachhaltigkeit |  |
| foc_119 | SFDR / EU-Taxonomie Reporting | Nachhaltigkeit | foc_115 |
| foc_065 | Abfallwirtschaft | Natur & Umwelt |  |
| foc_066 | Analytische Chemie | Natur & Umwelt |  |
| foc_057 | Bodenschutz | Natur & Umwelt | foc_056 |
| foc_064 | Fisch Auf- und Abstiege | Natur & Umwelt |  |
| foc_059 | Gewässerschutz | Natur & Umwelt | foc_056 |
| foc_058 | GWP | Natur & Umwelt | foc_056 |
| foc_062 | Landwirtschaft | Natur & Umwelt |  |
| foc_067 | Naturgefahren | Natur & Umwelt |  |
| foc_060 | Naturschutz | Natur & Umwelt | foc_056 |
| foc_063 | Regenwassermanagement | Natur & Umwelt |  |
| foc_056 | Umwelt | Natur & Umwelt |  |
| foc_061 | Umweltschutz | Natur & Umwelt | foc_056 |
| foc_088 | Baurecht | Normen & Recht |  |
| foc_091 | Garantie | Normen & Recht | foc_089 |
| foc_092 | Mängel | Normen & Recht | foc_089 |
| foc_087 | SIA | Normen & Recht |  |
| foc_089 | Vertragswesen | Normen & Recht |  |
| foc_090 | Werkverträge | Normen & Recht | foc_089 |
| foc_073 | Ausführungsplanung | Planung |  |
| foc_074 | Baubewilligung | Planung |  |
| foc_231 | Entwicklung | Planung |  |
| foc_075 | Entwurf | Planung |  |
| foc_077 | Generalplanung | Planung |  |
| foc_081 | Integrated Project Delivery (IPD) | Planung |  |
| foc_080 | Landschaftsarchitektur | Planung |  |
| foc_239 | Machbarkeitsstudie | Planung | ⚠️ DUPLIKAT → Alias auf foc_169 |
| foc_071 | Plan- und Schemaentwicklung | Planung |  |
| foc_202 | Plan- und Schemaentwicklung | Planung | ⚠️ DUPLIKAT → Alias auf foc_071 |
| foc_218 | Planung | Planung |  |
| foc_079 | Raumplanung | Planung |  |
| foc_072 | SIA Phase 31 Vorprojekt | Planung |  |
| foc_078 | Verkehrsplanung | Planung |  |
| foc_076 | Wettbewerb | Planung |  |
| foc_169 | Machbarkeitsstudie | Projektentwicklung |  |
| foc_205 | Issue-Management | Projektmanagement |  |
| foc_122 | Lean Construction | Projektmanagement | foc_120 |
| foc_120 | Projektmanagement | Projektmanagement |  |
| foc_121 | Teamleitung | Projektmanagement | foc_120 |
| foc_232 | Immobilien | Real Estate |  |
| foc_228 | Baubewilligung | Recht |  |
| foc_224 | Vertragswesen | Recht |  |
| foc_101 | Cyber Security | Sicherheit | foc_093 |
| foc_097 | Feuerwehr | Sicherheit | foc_093 |
| foc_095 | KOPAS | Sicherheit | foc_093 |
| foc_099 | Militär | Sicherheit | foc_093 |
| foc_241 | Operative Sicherheit | Sicherheit |  |
| foc_098 | Polizei | Sicherheit | foc_093 |
| foc_094 | Risiko und Sicherheit | Sicherheit | foc_093 |
| foc_096 | SIBE | Sicherheit | foc_093 |
| foc_093 | Sicherheit | Sicherheit |  |
| foc_100 | Zivilschutz | Sicherheit | foc_093 |
| foc_244 | Life Science | Spezialgebiete |  |
| foc_226 | Bahnbau | Tiefbau |  |
| foc_247 | Brückenbau | Tiefbau |  |
| foc_235 | Entwässerung | Tiefbau |  |
| foc_240 | Erhaltungsmanagement | Tiefbau |  |
| foc_250 | Geotechnik | Tiefbau |  |
| foc_252 | Grundbau | Tiefbau |  |
| foc_227 | Netzbau | Tiefbau |  |
| foc_246 | Spezialtiefbau | Tiefbau |  |
| foc_225 | Strassenbau | Tiefbau |  |
| foc_237 | Trasseebau | Tiefbau |  |
| foc_245 | Tunnelbau | Tiefbau |  |
| foc_236 | Verkehrsplanung | Tiefbau |  |
| foc_233 | Vermessung | Tiefbau |  |
| foc_234 | Werkleitungsbau | Tiefbau |  |
| foc_163 | Bauvermessung | Vermessung | foc_162 |
| foc_166 | Geoinformatik | Vermessung | foc_164 |
| foc_164 | GIS | Vermessung |  |
| foc_165 | GIS Systeme | Vermessung | foc_164 |
| foc_162 | Vermessung | Vermessung |  |
| foc_158 | Akquisition | Vertrieb & Marketing |  |
| foc_160 | Business Development | Vertrieb & Marketing |  |
| foc_161 | Kundenberatung | Vertrieb & Marketing |  |
| foc_157 | Marketing | Vertrieb & Marketing |  |
| foc_159 | Marktaufbau | Vertrieb & Marketing |  |
| foc_154 | Produkt Management | Vertrieb & Marketing |  |
| foc_156 | Verkauf | Vertrieb & Marketing | foc_155 |
| foc_155 | Vertrieb | Vertrieb & Marketing |  |

---

## 6. Branchen / Sektoren (dim_sector)

| ID | Name | Kategorie |
|-----|------|-----------|
| sec_019 | Architekturbüro | Bau- und Immobiliensektor |
| sec_022 | Baumanagement | Bau- und Immobiliensektor |
| sec_009 | Baustoffhandel | Bau- und Immobiliensektor |
| sec_028 | Bauunternehmung | Bau- und Immobiliensektor |
| sec_027 | Gebäudetechnik-Unternehmer | Bau- und Immobiliensektor |
| sec_020 | Generalplaner | Bau- und Immobiliensektor |
| sec_021 | GU/TU | Bau- und Immobiliensektor |
| sec_026 | Hersteller / Produzent | Bau- und Immobiliensektor |
| sec_024 | Holzbau | Bau- und Immobiliensektor |
| sec_023 | Immobilienunternehmen | Bau- und Immobiliensektor |
| sec_025 | Ingenieurbüro | Bau- und Immobiliensektor |
| sec_035 | Consultingunternehmen | Dienstleistungen |
| sec_013 | NGO | Dienstleistungen |
| sec_005 | Anlagefond | Finanzinstitutionen |
| sec_004 | Asset Management | Finanzinstitutionen |
| sec_002 | Bank | Finanzinstitutionen |
| sec_003 | Pensionskasse | Finanzinstitutionen |
| sec_006 | Private Equity | Finanzinstitutionen |
| sec_001 | Vermögensverwaltung | Finanzinstitutionen |
| sec_008 | Versicherung | Finanzinstitutionen |
| sec_016 | Alterszentrum | Gesundheitssektor |
| sec_018 | Biotechnologie | Gesundheitssektor |
| sec_017 | Pharma | Gesundheitssektor |
| sec_015 | Spital | Gesundheitssektor |
| sec_030 | Detailhandel | Industrie- und Konsumgüter |
| sec_029 | Industrieunternehmen | Industrie- und Konsumgüter |
| sec_034 | Maschinenindustrie | Industrie- und Konsumgüter |
| sec_033 | Mischkonzerne | Industrie- und Konsumgüter |
| sec_032 | Nahrungsmittel | Industrie- und Konsumgüter |
| sec_031 | Telekommunikation | Industrie- und Konsumgüter |
| sec_014 | Energieversorgung | Öffentlicher Sektor |
| sec_012 | Forschungsinstitut | Öffentlicher Sektor |
| sec_011 | Institution | Öffentlicher Sektor |
| sec_010 | Staatsbetrieb | Öffentlicher Sektor |
| sec_007 | Teilstaatliches Institut | Öffentlicher Sektor |

---

## 7. Sprachen (dim_languages)

| ID | Name |
|-----|------|
| lang_al | Albanisch |
| lang_ar | Arabisch |
| lang_bs | Bosnisch |
| lang_zh | Chinesisch |
| lang_de | Deutsch |
| lang_en | Englisch |
| lang_fr | Französisch |
| lang_el | Griechisch |
| lang_it | Italienisch |
| lang_ja | Japanisch |
| lang_hr | Kroatisch |
| lang_nl | Niederländisch |
| lang_pl | Polnisch |
| lang_pt | Portugiesisch |
| lang_ro | Rumänisch |
| lang_ru | Russisch |
| lang_sr | Serbisch |
| lang_es | Spanisch |
| lang_tr | Türkisch |
| lang_hu | Ungarisch |

---

## 8. Sparten (dim_sparte)

| ID | Name | Beschreibung |
|-----|------|-------------|
| ARC | Architecture | Architektur, Innenarchitektur und Design |
| GT | Building Technology | Gebäudetechnik, Netzthematiken, Energiesektor |
| ING | Civil Engineering | Ingenieurwesen, Umweltingenieure, Bauphysiker, Geotechnik |
| PUR | Procurement | Einkauf, Supply Chain, Beschaffung |
| REM | Real Estate Management | Immobilienmanagement, Immobilienentwicklung, Asset Mgmt |

---

## 9. Mitarbeiter (dim_mitarbeiter)

| ID | Name | Rolle | Rolle-Typ | Team | Status |
|-----|------|-------|-----------|------|--------|
| 6f8d4639-41db-4f72-a7bf-ae319ae2f820 | Hanna van den Bosch | Research Analyst | Research | Active |
| 396bb147-e9cc-43ef-b961-b679fa6488dc | Joaquin Vega | Candidate Manager | Candidate_Manager | Sales | Active |
| 4734bf7f-3bf5-4228-a52b-91de8f02e416 | Luca Rochat Ramunno | Research Analyst | Research | Active |
| 16985de2-35ac-4d25-b831-87331bcd28f3 | Nenad Stoparanovic | Admin | Admin | Recruiting | Active |
| 5ddecd88-945a-4167-880a-69aa392eaf5a | Nina Petrusic | Candidate Manager | Candidate_Manager | Recruiting | Active |
| 87daa7db-5df2-411f-a9d1-016e4439c457 | Peter Wiederkehr | Admin | Admin | Recruiting | Active |
| 0eeeaf90-b70f-4234-a78e-ffd58f8a4121 | Sabrina Tanner | Backoffice | Backoffice | Backoffice | Active |
| f169c80f-8917-4766-bab0-16af09a5d962 | Severina Nolan | Backoffice, Assessment Manager | Backoffice | Backoffice | Active |
| 789d99e2-5a87-4018-abe8-eac598d78f59 | Stefano Papes | Head of | Head_of | Backoffice | Active |
| e5989578-e029-4270-8079-6dd2a7ed16bb | Yavor Bojkov | Head of | Head_of | Sales | Active |

---

## 10. Owner Teams (aus dim_candidates_profile + dim_accounts)

Aktualisiert 14.04.2026 — Sparten-Code-konsistent (CI → ING).

| Code | Name | Sparten-Abdeckung |
|------|------|-------------------|
| `team_arc_rem` | Team ARC & REM | Architecture · Real Estate Management |
| `team_ing_bt` | Team ING & BT | Civil Engineering · Building Technology |

Die Procurement-Sparte (PUR) wird je nach Mandat einem der zwei Teams zugeordnet (kein eigenes Team).

---

## 10a. Kontakt-Org-Funktion (dim_org_functions) — NEU 14.04.2026

Ersetzt die zuvor geplanten Booleans `is_decision_maker`, `is_key_contact`, `is_champion`, `is_blocker` sowie die redundante Spalte `decision_level` auf `dim_account_contacts` (subjektiv, schlecht pflegbar). Stattdessen **organisatorische Funktion im Unternehmen** (objektiv, eindeutig). Konsolidiert auf 5 Codes (14.04.2026).

| Code | Label | Kurz | Typische Rollen |
|------|-------|------|-----------------|
| `vr_board` | VR / Board | V | VR-Präsident, VR-Mitglied, Stiftungsrat, Beirat |
| `executive` | Executive | E | CEO, COO, CFO, Bereichs-/Standortleiter, Projektleiter, Strategy, Controlling |
| `hr` | HR | H | HR-Leitung, Recruiter, HR-Business-Partner |
| `einkauf` | Einkauf | K | Leiter Einkauf, Vergabestelle, Procurement |
| `assistenz` | Assistenz | A | Assistenz GL, Office Management, Sekretariat |

**Single-Select** — ein Kontakt hat genau eine primäre Org-Funktion. Falls Doppel-Funktion (z.B. HR-Leitung = GL-Mitglied): Wahl nach Haupt-Verantwortlichkeit, Erläuterung im Drawer-Notizfeld.

---

## 10b. Dossier-Send-Preference (dim_dossier_preferences) — NEU 14.04.2026

Wie ein Account bevorzugt Kandidaten-Dossiers/Exposés erhält. Account-spezifische Stammdaten-Liste, ergänzbar.

| Code | Name | Beschreibung |
|------|------|-------------|
| `email_hr` | Per E-Mail an HR-Leitung | Standard-Versand an HR / Personalabteilung |
| `email_decision_maker` | Per E-Mail an Entscheider | Direkt an CEO / VR-Mitglied / Bereichsleiter |
| `email_assistenz` | Per E-Mail an Assistenz | Sekretariat / Persönliche Assistenz |
| `portal_upload` | Hochladen auf Kundenportal | Bewerbungs-Plattform mit Login-Zugang |
| `physisch_post` | Physisch per Post | Print-Dossier per A-Post / Einschreiben |
| `physisch_persoenlich` | Persönliche Übergabe | Im Termin / Meeting persönlich |
| `nicht_definiert` | Nicht definiert | Default falls noch nicht abgeklärt |

---

## 10c. Vorstellungs-Typ (dim_presentation_types) — NEU 14.04.2026

Wie ein Kandidat bei einem Account formell vorgestellt wurde (beweisrelevant für Schutzfrist / Claim-Workflow). Fixes Enum, nicht ergänzbar ohne PO-Freigabe.

| Code | Name | Beschreibung |
|------|------|-------------|
| `email_dossier` | Dossier per E-Mail | Exposé/Dossier per Mail an Account versandt (Standardfall, Gate-2 Jobbasket) |
| `verbal_meeting` | Mündlich im Meeting mit Dossier-Share | Kandidat im Teams/Präsenz-Meeting vorgeschlagen, Dossier geteilt, aber nicht nachgeschickt |
| `upload_portal` | Upload Kundenportal | Dossier im Bewerber-/Vendor-Portal des Kunden hochgeladen |

**Regel:** Reine Telefon-/Chat-Erwähnung ohne Dossier-Transfer löst **keine** Schutzfrist aus (kein Audit-Beleg).

---

## 11. Kandidaten-Stages — AKTUALISIERT v1.2

| Stage | Reihenfolge | Automatischer Trigger | Manuell änderbar? |
|-------|------------|----------------------|-------------------|
| Check | 1 | Default bei candidate.created | ✅ Ja |
| Refresh | 2 | Ghosting/NIC/Dropped. Nach 1 Jahr in Datenschutz. | ✅ Ja |
| Premarket | 3 | History: Briefing/Rebriefing | ✅ Ja |
| Active Sourcing | 4 | Briefing + Original CV + Diplom + Arbeitszeugnis | ✅ Ja |
| Market Now | 5 | Aktiver Prozess vorhanden | ✅ Ja |
| Inactive | 6 | Alter > 60 oder Cold > 6 Monate (täglicher Job) | ✅ Ja |
| Blind | 7 | — (nur manuell) | ✅ Ja |
| Datenschutz | 8 | POST /candidates/:id/anonymize | ✅ Ja (Sonder-Automation) |

**Hinweise v1.2:**
- Datenschutz: Nach 1 Jahr automatisch auf Refresh gestellt (Sonder-Automation die Terminal-Status überschreiben darf). Auch manuell rückstellbar falls Kandidat sich selbst wieder meldet. Gelöschte Daten müssen neu erfasst werden.
- Bei NIC, Dropped, Nicht mehr erreichbar: Stage-Update auch in allen aktiven Longlists
- Bei Rückstufung von Market Now: automatisch wenn alle Prozesse geschlossen werden

**Kandidaten-Temperatur:** Hot | Warm | Cold (Dringlichkeit aus ARK-Sicht)

**Wechselmotivation (NEU v1.2):** Faktische Situation des Kandidaten

| Stufe | Beschreibung |
|---|---|
| Arbeitslos | Kandidat ist derzeit nicht beschäftigt |
| Will/muss wechseln | Aktive Suche, dringendes Bedürfnis |
| Will/muss wahrscheinlich wechseln | Hohe Wahrscheinlichkeit für Wechsel |
| Wechselt bei gutem Angebot | Offen wenn das Angebot stimmt |
| Wechselmotivation spekulativ | Unklare Signale |
| Wechselt gerade intern & will abwarten | Interner Wechsel, wartet ab |
| Will absolut nicht wechseln | Klar kommuniziert: kein Interesse |
| Will nicht mit uns zusammenarbeiten | Hat ARK als Partner abgelehnt |

---

## 12. Mandat-Research-Stages (fact_mandate_research.contact_status)

### DB-Feld-Mapping

| Stage (Anzeigename) | DB-Wert (contact_status) | Automatisch? | Gesperrt? |
|---------------------|-------------------------|-------------|-----------|
| Research | research | Nein (manuell) | Nein |
| Nicht erreicht | nicht_erreichbar | Nein (manuell) | Nein |
| Nicht mehr erreichbar | nicht_mehr_erreichbar | Nein (manuell) | Nein |
| Nicht interessiert | nicht_interessiert | Nein (manuell) | Nein |
| Dropped | dropped | Nein (manuell) | Nein |
| CV Expected | cv_expected | Nein (manuell) | Nein |
| CV IN | cv_in | ✅ Ja (Original CV hochgeladen) | ✅ Gesperrt |
| Briefing | briefing | ✅ Ja (Briefing-History) | ✅ Gesperrt |
| GO mündlich | go_muendlich | ✅ Ja (Mündl. GOs History) | ✅ Gesperrt |
| GO schriftlich | go_schriftlich | ✅ Ja (Schriftl. GOs History) | ✅ Gesperrt |
| Rejected oral GO | rejected_oral_go | Nein (manuell) | Nein |
| Rejected written GO | rejected_written_go | Nein (manuell) | Nein |
| Ghosted | ghosted | Nein (manuell) | Nein |

### Vorwärts-Progression

| Stage | Order | Kategorie | Beschreibung |
|-------|-------|-----------|-------------|
| Research | 1 | Longlist | Kandidat wurde in Longlist hinzugefügt, muss kontaktiert werden vom Research Analyst |
| Nicht erreicht | 2 | Kontaktberührung | Kandidat wurde kontaktiert aber nie erreicht (NE, Combox etc.) |
| Nicht mehr erreichbar | 3 | Kontaktberührung | Kandidat nicht mehr auffindbar (verstorben, ausgewandert, nicht auffindbar) |
| Nicht interessiert | 4 | Erreicht - Absage | Kandidat hat das Gespräch / die Position abgelehnt |
| Dropped | 5 | Erreicht - Absage | Kandidat wurde als untauglich befunden (wir droppen) |
| CV Expected | 6 | Erreicht - Positiv | Briefing vereinbart, Kandidat hat CV-Zusendung versprochen |
| CV IN | 7 | Erreicht - Positiv | CV wurde geschickt und ins System eingetragen |
| Briefing | 8 | Erreicht - Positiv | Kandidat wurde (neu) gebrieft oder war bereits im Active Sourcing gebrieft |
| GO mündlich | 9 | GO-Flow | GO für Position abgeholt, Email mit Bitte um schriftliche Bestätigung versendet |
| GO schriftlich | 10 | GO-Flow | Kandidat hat GO schriftlich rückbestätigt |

### GO-Rejections (Exit-Points)

| Stage | Kategorie | Beschreibung |
|-------|-----------|-------------|
| Rejected oral GO | GO-Rejection | Kandidat hat GO mündlich abgelehnt |
| Rejected written GO | GO-Rejection | Kandidat hat schriftliches GO nicht bestätigt / abgelehnt |
| Ghosted | GO-Rejection | Kandidat hat nach schriftlichem GO-Mail nicht mehr reagiert (Timeout z.B. 14 Tage) |

### GO-Rejection Reasons (für Rejected oral GO und Rejected written GO)

Referenziert dim_rejection_reasons_candidate (gleiche Tabelle wie Kandidaten-Absagegründe).
Bei Ghosted: kein Grund erforderlich (NULL erlaubt).

| Reason | Beschreibung |
|--------|-------------|
| Compensation | Lohn oder Gesamtpaket nicht attraktiv genug |
| Role not attractive | Position / Aufgaben passen nicht |
| Company not attractive | Firma oder Unternehmenskultur passt nicht |
| Location | Standort oder Pendeldistanz passt nicht |
| Timing | Zeitpunkt für Wechsel nicht passend |
| Counter Offer | Kandidat erhält Gegenangebot vom aktuellen Arbeitgeber |
| Personal reasons | Persönliche Gründe |
| Stay with current employer | Kandidat entscheidet sich zu bleiben |
| Unknown | Grund unbekannt |

### Weiterführung nach GO schriftlich

Nach **GO schriftlich** geht der Kandidat in den **Jobbasket-Flow** über:

```
GO schriftlich → Jobbasket (Prelead → Mündl. GO → Schriftl. GO → Assigned → To Send)

Gate 1 – Assigned:     Schriftl. GO + Original CV + Diplom + Arbeitszeugnis
Gate 2 – Versand:      ARK CV + Abstract → CV Sent  |  Exposé → Exposé Sent

Nach Versand → Prozess automatisch erstellt:
  CV Sent    → Prozess Stage 'CV Sent'
  Exposé Sent → Prozess Stage 'Expose'
```

Ab **CV Sent** läuft der Kandidat in der normalen **Prozess-Pipeline** weiter:

```
Expose → CV Sent → TI → 1st → 2nd → 3rd → Assessment → Offer → Placement
```

Alle Prozess-Stages, Rejection-Stages und Outcomes aus Abschnitt 13-20 gelten auch für Mandat-Prozesse.

---

## 13. Prozess-Stages (dim_process_stages)

| Stage | Order | Kategorie | Win-Probability | is_pipeline_stage |
|-------|-------|-----------|----------------|-------------------|
| Expose | 1 | Pipeline | 5% | ✅ true |
| CV Sent | 2 | Pipeline | 10% | ✅ true |
| TI | 3 | Pipeline | 20% | ✅ true |
| 1st | 4 | Pipeline | 35% | ✅ true |
| 2nd | 5 | Pipeline | 55% | ✅ true |
| 3rd | 6 | Pipeline | 70% | ✅ true |
| Assessment | 7 | Pipeline | 70% | ✅ true |
| Offer | 8 | Pipeline | 80% | ✅ true |
| Placement | 9 | Success | 100% | ✅ true |
| On hold unseen | 10 | On Hold | --- | false (Analytics) |
| On hold interview | 11 | On Hold | --- | false (Analytics) |
| Rejected unseen | 12 | Rejected | --- | false (Analytics) |
| Rejected TI | 13 | Rejected | --- | false (Analytics) |
| Rejected 1st | 14 | Rejected | --- | false (Analytics) |
| Rejected 2nd | 15 | Rejected | --- | false (Analytics) |
| Rejected 3rd | 16 | Rejected | --- | false (Analytics) |
| Offer refused | 17 | Rejected | --- | false (Analytics) |
| Cancellation | 18 | Post Placement | --- | false (Analytics) |
| Dropped | 19 | Dropped | --- | false (Analytics) |

**Hinweis:** Nur Stages mit `is_pipeline_stage = true` sind gültige Werte für
`fact_process_core.current_process_stage`. Die anderen sind Analytics-Labels die
vom Backend aus Status + rejected_stage berechnet werden (für Power BI/Reporting).

---

## 13b. Prozess-Status (dim_process_status) — AKTUALISIERT v1.2

| Status | Kategorie | Beschreibung |
|--------|-----------|-------------|
| Open | Active | Prozess ist aktiv und läuft |
| On Hold | Paused | Prozess ist pausiert (Kunde oder intern) |
| Rejected | Closed | Kandidat wurde im Prozess abgelehnt (rejected_by + reason Pflicht) |
| Placed | Success | Kandidat wurde erfolgreich platziert |
| Cancelled | Closed | Rückzieher nach Placement — Kandidat zieht nach Zusage zurück (100% Rückvergütung) |
| Dropped | Closed | Prozess kam nicht zustande |
| Stale | Degraded | Prozess ist seit > X Tagen inaktiv (konfigurierbar, Default 14 Tage) |
| Closed | Closed | Prozess regulär abgeschlossen (Garantiefrist abgelaufen) |

---

## 14. Activity Types (dim_activity_types) — ÜBERARBEITET v1.3 (2026-04-16)

> **Scope: Alle Activity-Types sind Arkadium-Aktivitäten.** Interview-Durchführungen (TI / 1st / 2nd / 3rd / Assessment) sind **keine** Activity-Types — sie sind Stage-Daten (`fact_process_interviews.actual_date`) und laufen direkt zwischen Kunde und Kandidat (CLAUDE.md §Arkadium-Rolle-Regel).
>
> **Terminologie (4 Arkadium-Touchpoints):**
> - **Briefing** = Arkadium ↔ Kandidat Eignungsgespräch nach Hunt/Research (System-Event `#62 Briefing` wird beim erstmaligen Speichern der Briefing-Maske erzeugt; das eigentliche Gespräch wird typischerweise als `#20 Erreicht - GO Termin aus oder im Briefing` geloggt)
> - **Coaching** = Arkadium ↔ Kandidat vor Interview (`#36/38/40/65` je Stage)
> - **Debriefing** = Arkadium ↔ Kandidat ODER Arkadium ↔ Kunde nach Interview (`#37/39/41/66` je Stage — pro Debriefing-Set zwei Einträge mit identischem Activity-Type, einmal in Kandidat-History und einmal in Account-History; die Entity-Zuordnung ergibt sich aus der History-Location)
> - **Referenzauskunft** = Arkadium ↔ Referenzperson im Kunden-Auftrag (`#42`)
>
> **Nicht verwechseln:** „Briefing" (Kandidat-Eignungsgespräch) ≠ „Stellenbriefing" (Kunde über Stelle) ≠ „Coaching" (Interview-Vorbereitung mit Kandidat).
>
> 61+ Activity-Types in 11 Kategorien. NIC = Not Interested Currently.
> Kanal-Mapping: Call → Phone, Email → Email, Meeting → In-Person
> is_auto = true: System-Einträge die ohne Consultant-Input erstellt werden
> **entity_relevance:** Default-Zuordnung zu Entity-History (`candidate` / `account` / `both`). Bei `both` kann die Activity mehrfach in unterschiedlichen Histories erscheinen (z.B. Debriefing: 1× in Kandidat-History + 1× in Account-History).

### Kontaktberührung (6 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 1 | Kontaktberührung - NE | Kontaktberührung | Phone | - | candidate | Kontaktversuch ohne Antwort |
| 2 | Kontaktberührung - NE - Direkt Combox | Kontaktberührung | Phone | - | candidate | Anruf ohne Klingeln direkt auf Combox |
| 3 | Kontaktberührung - NE - Combox Nachricht | Kontaktberührung | Phone | - | candidate | Nachricht auf Combox hinterlassen |
| 4 | Kontaktberührung - NE - Notiz | Kontaktberührung | Phone | - | candidate | Notiz zu Kontaktversuch |
| 5 | Kontaktberührung - NE - Briefing nicht wahrgenommen | Kontaktberührung | Phone | - | candidate | Kandidat hat zum Briefing nicht abgenommen |
| 6 | Kontaktberührung - Nicht mehr erreichbar | Kontaktberührung | Phone | - | candidate | Kandidat dauerhaft nicht erreichbar |

### Erreicht (15 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 7 | Erreicht - NIC vor Rollenspiel | Erreicht | Phone | - | candidate | Kandidat hat aufgelegt oder gleich abgeblockt |
| 8 | Erreicht - NIC nach Rollenspiel | Erreicht | Phone | - | candidate | Kandidat hat nach dem Rollenspiel abgelehnt |
| 9 | Erreicht - NIC inneres Ich | Erreicht | Phone | - | candidate | Kandidat hat im Austausch über das innere Ich abgelehnt |
| 10 | Erreicht - NIC Pitch | Erreicht | Phone | - | candidate | Kandidat hat nach dem Pitch den Termin abgelehnt |
| 11 | Erreicht - CV expected | Erreicht | Phone | - | candidate | Kandidat sendet CV und Briefing vereinbart |
| 12 | Erreicht - Meeting vor Ort | Erreicht | In-Person | - | candidate | Persönliches Treffen |
| 13 | Erreicht - Dropped | Erreicht | Phone | - | candidate | Kandidat nicht passend (Profil, Fachkenntnisse etc.) |
| 14 | Erreicht - Appointment | Erreicht | Phone | - | candidate | Telefontermin vereinbart |
| 15 | Erreicht - Update Call | Erreicht | Phone | - | both | Update Gespräch mit Kandidat oder Kunde |
| 16 | Erreicht - Doc Chase | Erreicht | Phone | - | candidate | Nachfassen wegen Dokumenten |
| 17 | Erreicht - CV Chase | Erreicht | Phone | - | candidate | Nachfassen wegen CV |
| 18 | Erreicht - GO Chase | Erreicht | Phone | - | candidate | Nachfassen wegen Go-Freigabe |
| 19 | Erreicht - GO Termin aus Rebriefing oder Refresh | Erreicht | Phone | - | candidate | GO Termin aus Rebriefing oder Refresh |
| 20 | Erreicht - GO Termin aus oder im Briefing | Erreicht | Phone | - | candidate | GO Termin aus Briefing (Arkadium ↔ Kandidat Eignungsgespräch) |
| 21 | Erreicht - Absage im GO Termin | Erreicht | Phone | - | candidate | Kandidat hat alle Preleads abgelehnt |

### Emailverkehr (11 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 22 | Emailverkehr - Allgemeine Kommunikation | Emailverkehr | Email | - | both | Allgemeine Email Kommunikation |
| 23 | Emailverkehr - CV Chase | Emailverkehr | Email | - | candidate | Email Nachfassen wegen CV |
| 24 | Emailverkehr - Absage Briefing | Emailverkehr | Email | - | candidate | Kandidat sagt Briefing schriftlich ab |
| 25 | Emailverkehr - Absage Bewerbung | Emailverkehr | Email | - | account | Kunde sagt nach CV Sent ab |
| 26 | Emailverkehr - Absage vor GO Termin | Emailverkehr | Email | - | candidate | Absage vor dem GO Termin |
| 27 | Emailverkehr - Mündliche GOs versendet | Emailverkehr | Email | - | account | Mündliche GO-Freigaben versendet |
| 28 | Emailverkehr - Absage nach GO Termin | Emailverkehr | Email | - | account | Absage von mündlichen Go Freigaben (Kunde lehnt ab) |
| 29 | Emailverkehr - Schriftliche GOs | Emailverkehr | Email | - | account | Schriftliche GO Bestätigung (eingehend vom Kunde) |
| 30 | Emailverkehr - Eingangsbestätigung Bewerbung | Emailverkehr | Email | - | candidate | Bestätigung Bewerbungseingang |
| 31 | Emailverkehr - Mandatskommunikation | Emailverkehr | Email | - | account | Kommunikation zum Mandat |
| 32 | Emailverkehr - AGB Verhandlungen | Emailverkehr | Email | - | account | Verhandlung von AGB |

### Messaging (3 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 33 | Messaging - LinkedIn | Messaging | LinkedIn | - | both | Nachricht über LinkedIn (Kandidat oder Kunde) |
| 34 | Messaging - Xing | Messaging | Xing | - | both | Nachricht über Xing (Kandidat oder Kunde) |
| 35 | Messaging - SMS / Whatsapp | Messaging | Whatsapp | - | both | SMS oder WhatsApp Nachricht (Kandidat oder Kunde) |

### Interviewprozess (9 Einträge — TI ergänzt 2026-04-16)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 36 | Erreicht - Coaching 1st Interview | Interviewprozess | Phone | - | candidate | Vorbereitung auf erstes Interview (Arkadium ↔ Kandidat) |
| 37 | Erreicht - Debriefing 1st Interview | Interviewprozess | Phone | - | both | Nachbesprechung erstes Interview — zwei History-Einträge pro Set (1× Kandidat-History, 1× Account-History) |
| 38 | Erreicht - Coaching 2nd Interview | Interviewprozess | Phone | - | candidate | Vorbereitung zweites Interview (Arkadium ↔ Kandidat) |
| 39 | Erreicht - Debriefing 2nd Interview | Interviewprozess | Phone | - | both | Nachbesprechung zweites Interview — beidseitig |
| 40 | Erreicht - Coaching 3rd Interview | Interviewprozess | Phone | - | candidate | Vorbereitung drittes Interview (Arkadium ↔ Kandidat) |
| 41 | Erreicht - Debriefing 3rd Interview | Interviewprozess | Phone | - | both | Nachbesprechung drittes Interview — beidseitig |
| 42 | Erreicht - Referenzauskunft | Interviewprozess | Phone | - | candidate | Referenzauskunft eingeholt (Arkadium ↔ Referenzperson im Kunden-Auftrag; Kandidaten-bezogen) |
| 65 | Erreicht - Coaching TI | Interviewprozess | Phone | - | candidate | Vorbereitung auf Telefon-/Teams-Interview (Arkadium ↔ Kandidat) — NEU 2026-04-16 |
| 66 | Erreicht - Debriefing TI | Interviewprozess | Phone | - | both | Nachbesprechung Telefon-/Teams-Interview — beidseitig (Kandidat + Kunde je eigener History-Eintrag) — NEU 2026-04-16 |

### Placementprozess (6 Einträge — 1./2./3.-Mt-Checks ergänzt 2026-04-16)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 43 | Erreicht - Offerbesprechung | Placementprozess | Phone | - | both | Besprechung des Angebots (Arkadium ↔ Kandidat oder ↔ Kunde) |
| 44 | Erreicht - Placement Call | Placementprozess | Phone | - | candidate | Placement Gespräch (Arkadium ↔ Kandidat) |
| 45 | Erreicht - Onboarding Call | Placementprozess | Phone | - | candidate | Onboarding Gespräch 1 Woche vor Start (Arkadium ↔ Kandidat) |
| 67 | Erreicht - 1-Mt-Check | Placementprozess | Phone | - | candidate | Post-Placement Check-in im 1. Monat nach Arbeitsantritt (Arkadium ↔ Kandidat) — NEU 2026-04-16 |
| 68 | Erreicht - 2-Mt-Check | Placementprozess | Phone | - | candidate | Post-Placement Check-in im 2. Monat (Arkadium ↔ Kandidat) — NEU 2026-04-16 |
| 69 | Erreicht - 3-Mt-Check | Placementprozess | Phone | - | candidate | Post-Placement Check-in im 3. Monat · deckungsgleich mit Garantiefrist-Ende (AGB §5) · danach keine weiteren Checks — NEU 2026-04-16 |

### Refresh Kandidatenpflege (3 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 46 | Erreicht - Refresh in Probezeit | Refresh Kandidatenpflege | Phone | - | candidate | Follow-up während Probezeit (Arkadium ↔ Kandidat) |
| 47 | Erreicht - Refresh Not Interested Currently | Refresh Kandidatenpflege | Phone | - | candidate | Refresh Kandidat aktuell nicht interessiert |
| 48 | Erreicht - Refresh offen für GOs | Refresh Kandidatenpflege | Phone | - | candidate | Refresh Kandidat offen für GOs |

### Mandatsakquise (4 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 49 | Erreicht - Mandatshunt | Mandatsakquise | Phone | - | account | Neukundenansprache für Mandat (Arkadium ↔ Kunde) |
| 50 | Erreicht - Mandatsbesprechung | Mandatsakquise | Phone | - | account | Besprechung eines Mandats (Arkadium ↔ Kunde) |
| 51 | Erreicht - Mandatsverhandlung | Mandatsakquise | Phone | - | account | Verhandlung eines Mandats (Arkadium ↔ Kunde) |
| 52 | Erreicht - AGB Verhandlungen | Mandatsakquise | Phone | - | account | AGB Verhandlung telefonisch (Arkadium ↔ Kunde) |

### Erfolgsbasis (2 Einträge) — NEU v1.2

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 53 | Erfolgsbasis - AGB Verhandlungen | Erfolgsbasis | Phone | - | account | AGB Verhandlung für Erfolgsbasis-Prozesse |
| 54 | Erfolgsbasis - AGB bestätigt | Erfolgsbasis | Email | - | account | Kunde hat AGB schriftlich bestätigt (eingehend) |

### Assessment (4 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 55 | Assessment - Link versendet | Assessment | Email | - | candidate | Assessment-Link an Kandidat versendet |
| 56 | Assessment - Ergebnisse erfasst | Assessment | System | ✓ | candidate | Assessment-Daten im System erfasst |
| 57 | Erreicht - Assessment Akquise | Assessment | Phone | - | account | Akquise für Assessment beim Kunden |
| 58 | Erreicht - Assessmentbesprechung | Assessment | Phone | - | account | Besprechung Assessment-Ergebnisse mit Kunde |

### System / Meta (6 Einträge)

| # | Activity Type | Kategorie | Kanal | is_auto | entity_relevance | Beschreibung |
|---|---|---|---|---|---|---|
| 59 | Keine Preleads | System | System | - | candidate | Keine passenden Preleads vorhanden |
| 60 | Inactive | System | System | ✓ | candidate | Kandidat automatisch auf Inactive gesetzt |
| 61 | GO Ghosting | System | System | ✓ | candidate | Kandidat hat nach mündlichen GOs nicht reagiert |
| 62 | Briefing | System | System | ✓ | candidate | Briefing-Maske erstmalig gespeichert |
| 63 | Rebriefing | System | System | ✓ | candidate | Briefing-Maske erneut gespeichert (bereits Briefing vorhanden) |
| 64 | Schutzfrist - Status-Änderung | System | System | ✓ | both | Auto-Log bei jedem State-Change in `fact_protection_window` / Claim-Workflow (eröffnet, verlängert, klassifiziert Fall X/Y/Z, Rechnung erstellt, Kulanz-Abschluss). Detail-Text aus State-Transition generiert. NEU 14.04.2026 |

### Statistik

```
Total Activity-Types:           69  (2 TI-Einträge + 3 Post-Placement-Check-Einträge ergänzt 2026-04-16)
  davon is_auto_logged = true:   6 (Inactive, GO Ghosting, Briefing, Rebriefing, Assessment Ergebnisse, Schutzfrist Status-Änderung)
  davon is_auto_logged = false: 60 (manuelle Erfassung / Confirm durch Mitarbeiter)
Kategorien:                     11
entity_relevance-Verteilung (grob):
  candidate-only: ~39 (Kontaktberührung 6, Erreicht 14, Emailverkehr 4, Interviewprozess 5, Placement 2, Refresh 3, Assessment 2, System 5)
  account-only:   ~17 (Emailverkehr 6, Mandatsakquise 4, Erfolgsbasis 2, Assessment 2, Coaching-Seiten n/a)
  both:           ~10 (Update Call, Allg. Emailverkehr, 3× Messaging, Debriefings, Offerbesprechung, Schutzfrist-State)
```
---

## 15. Absagegruende Kandidat (dim_rejection_reasons_candidate)

| Grund | Kategorie | Beschreibung |
|-------|-----------|-------------|
| Compensation | Candidate Decision | Lohn oder Gesamtpaket nicht attraktiv genug |
| Role not attractive | Candidate Decision | Rolle oder Aufgaben passen nicht |
| Company not attractive | Candidate Decision | Kunde oder Unternehmenskultur passt nicht |
| Location | Candidate Decision | Standort oder Pendeldistanz passt nicht |
| Timing | Candidate Decision | Zeitpunkt für Wechsel nicht passend |
| Counter Offer | Candidate Decision | Kandidat erhält Gegenangebot vom aktuellen Arbeitgeber |
| Personal Reasons | Candidate Decision | Persönliche Gründe |
| Stay with current employer | Candidate Decision | Kandidat entscheidet sich zu bleiben |
| Offer refused | Candidate Decision | Kandidat lehnt konkretes Angebot ab |
| Process too slow | Process Issue | Kandidat verliert Interesse wegen langer Prozessdauer |
| Lost interest | Process Issue | Kandidat verliert Interesse im Verlauf |
| No feedback | Process Issue | Kandidat fühlt sich schlecht betreut oder informiert |
| Unknown | Unknown | Absagegrund unbekannt |

---

## 16. Absagegruende Kunde (dim_rejection_reasons_client)

| Grund | Kategorie | Beschreibung |
|-------|-----------|-------------|
| Skills mismatch | Profile Fit | Fachliche Kompetenzen passen nicht |
| Industry mismatch | Profile Fit | Branchenhintergrund passt nicht |
| Seniority mismatch | Profile Fit | Erfahrungsniveau passt nicht |
| Leadership mismatch | Profile Fit | Führungserfahrung passt nicht |
| Cultural fit | Personal Fit | Persönlichkeit oder kulturelle Passung fehlt |
| Communication | Personal Fit | Auftreten oder Kommunikation überzeugt nicht |
| Motivation | Motivation | Kandidat wirkt nicht ausreichend motiviert |
| Salary too high | Compensation | Lohnvorstellung zu hoch |
| Availability too late | Availability | Verfügbarkeit oder Kündigungsfrist passt nicht |
| Location | Availability | Standort oder Mobilität passt nicht |
| Better candidates available | Market Comparison | Andere Kandidaten waren stärker |
| Job on hold | Process Issue | Position wurde pausiert |
| Role changed | Process Issue | Anforderungsprofil hat sich verändert |
| Internal candidate | Process Issue | Kunde besetzt intern |
| No longer hiring | Process Issue | Kunde rekrutiert nicht mehr |
| Unknown | Unknown | Absagegrund unbekannt |

---

## 17. Cancellation Reasons (dim_cancellation_reasons) — KORRIGIERT v1.2

> Cancellation = Rückzieher des Kandidaten NACH Placement (nach Zusage).
> NICHT Mandats-Abbruch. 100% Rückvergütung fällig.

| Grund | Beschreibung |
|-------|-------------|
| Candidate resigned | Kandidat kündigt nach Zusage / vor Stellenantritt |
| Company termination | Firma kündigt dem Kandidaten |
| Role mismatch | Rolle passt nicht wie vereinbart |
| Cultural mismatch | Kultur passt nicht |
| Relocation | Umzug nicht möglich / gewollt |
| Counter offer accepted | Kandidat nimmt Gegenangebot des aktuellen Arbeitgebers an |
| Unknown | Unbekannt |

---

## 18. Dropped Reasons

| Grund | Beschreibung |
|-------|-------------|
| Position already filled | Stelle bereits besetzt |
| Client not working with agency | Kunde arbeitet nicht mit uns |
| Internal hire | Intern besetzt |
| Budget stopped | Budget gestrichen |
| Unknown | Unbekannt |

---

## 19. Offer Refused Reasons

| Grund | Kategorie |
|-------|-----------|
| Compensation | Candidate Decision |
| Counter Offer | Candidate Decision |
| Role not attractive | Candidate Decision |
| Location | Candidate Decision |
| Stay with current employer | Candidate Decision |
| Unknown | Unknown |

---

## 20. Final Outcomes (Mandat)

| Outcome | Kategorie | Beschreibung |
|---------|-----------|-------------|
| Placement | Success | Kandidat hat Angebot angenommen und unterschrieben |
| Client Rejected | Client Rejection | Kunde lehnt Kandidaten im Prozess ab |
| Candidate Rejected | Candidate Rejection | Kandidat zieht sich im Prozess zurück |
| Offer Refused | Candidate Rejection | Kandidat lehnt Angebot ab |
| Dropped | Process Lost | Prozess wurde nie gestartet oder Kunde arbeitet nicht über uns |
| Cancellation | Post Placement | Kandidat kündigt nach Placement |
| On Hold | Process Paused | Prozess wurde pausiert |
| Open | Process Active | Prozess läuft noch |

---

## 21. Rollen (dim_roles) — NEU v1.1

| role_key | role_name | role_category | Beschreibung |
|----------|-----------|---------------|-------------|
| Admin | Administrator | system | Voller Zugriff auf alle Funktionen |
| Candidate_Manager | Candidate Manager | operations | Verantwortlich für Kandidatenpflege und Prozesse |
| Account_Manager | Account Manager | operations | Verantwortlich für Kundenbeziehungen und Mandate |
| Researcher | Research Analyst | operations | Longlist-Recherche und Kandidatenidentifikation |
| Head_of | Head of Division | management | Spartenleitung mit erweitertem Zugriff |
| Backoffice | Backoffice | support | Administrative Unterstützung |
| Assessment_Manager | Assessment Manager | operations | Verantwortlich für Assessments und Persönlichkeitsanalysen |
| ReadOnly | Nur Lesen | system | Nur Leserechte, kein Schreibzugriff |

**Multi-Rollen:** Ein Mitarbeiter kann mehrere Rollen gleichzeitig haben (z.B. Severina = Backoffice + Assessment_Manager). Zuordnung über bridge_mitarbeiter_roles.

### Mitarbeiter-Rollen-Zuordnung

| Mitarbeiter | Primäre Rolle | Weitere Rollen |
|-------------|--------------|----------------|
| Hanna van den Bosch | Researcher | — |
| Joaquin Vega | Candidate_Manager | — |
| Luca Rochat Ramunno | Researcher | — |
| Nenad Stoparanovic | Admin | — |
| Nina Petrusic | Candidate_Manager | — |
| Peter Wiederkehr | Admin | — |
| Sabrina Tanner | Backoffice | — |
| Severina Nolan | Backoffice | Assessment_Manager |
| Stefano Papes | Head_of | — |
| Yavor Bojkov | Head_of | — |

---

## 22. Event Types (dim_event_types) — AKTUALISIERT v1.2

| event_category | entity_type | event_name | is_automatable |
|---------------|-------------|------------|----------------|
| candidate | candidate | candidate.created | true |
| candidate | candidate | candidate.updated | true |
| candidate | candidate | candidate.stage_changed | true |
| candidate | candidate | candidate.deleted | true |
| candidate | candidate | candidate.restored | true |
| candidate | candidate | candidate.merged | true |
| candidate | candidate | candidate.anonymized | false |
| candidate | candidate | candidate.datenschutz_requested | true |
| candidate | candidate | candidate.linkedin_imported | true |
| candidate | candidate | candidate.temperature_changed | true |
| candidate | candidate | candidate.wechselmotivation_changed | true |
| process | process | process.created | true |
| process | process | process.stage_changed | true |
| process | process | process.placed | true |
| process | process | process.closed | true |
| process | process | process.reopened | true |
| process | process | process.on_hold | true |
| process | process | process.rejected | true |
| process | process | process.stale_detected | true |
| job | job | job.created | true |
| job | job | job.stage_changed | true |
| job | job | job.filled | true |
| job | job | job.cancelled | true |
| job | job | job.vacancy_detected | true |
| job | job | job.published | true |
| job | job | job.filled_externally | true |
| mandate | mandate | mandate.created | true |
| mandate | mandate | mandate.stage_changed | true |
| mandate | mandate | mandate.completed | true |
| mandate | mandate | mandate.cancelled | true |
| mandate | mandate | mandate.activated | true |
| mandate | mandate | mandate.research_stage_changed | true |
| jobbasket | candidate | jobbasket.candidate_added | true |
| jobbasket | candidate | jobbasket.go_oral | true |
| jobbasket | candidate | jobbasket.go_written | true |
| call | call | call.received | true |
| call | call | call.transcript_ready | true |
| call | call | call.missed | true |
| email | email | email.received | true |
| email | email | email.sent | true |
| email | email | email.bounced | true |
| document | document | document.uploaded | true |
| document | document | document.cv_parsed | true |
| document | document | document.ocr_done | true |
| document | document | document.embedded | true |
| document | document | document.reparsed | true |
| system | history | history.created | true |
| system | history | history.ai_summary_ready | true |
| scrape | account | scrape.change_detected | true |
| scrape | account | scrape.new_job_detected | true |
| scrape | account | scrape.person_left | true |
| scrape | account | scrape.new_person | true |
| scrape | account | scrape.role_changed | true |
| match | match | match.score_updated | true |
| match | match | match.suggestion_ready | true |
| account | account | account.contact_left | true |
| reminder | reminder | reminder.overdue | true |
| system | assessment | assessment.completed | true |
| system | assessment | assessment.invite_sent | true |
| system | assessment | assessment.expired | true |
| system | system | system.data_quality_issue | false |
| system | system | system.circuit_breaker_tripped | false |
| system | system | system.dead_letter_alert | false |
| system | system | system.retention_action | false |

**v1.2 Änderungen:** skill.market_value_updated ENTFERNT (Skills deprecated). 12 neue Events hinzugefügt (candidate.temperature_changed, candidate.wechselmotivation_changed, process.stale_detected, job.filled_externally, mandate.activated, mandate.research_stage_changed, jobbasket.candidate_added, jobbasket.go_oral, jobbasket.go_written, account.contact_left, reminder.overdue, process.on_hold war bereits vorhanden).

---

## 23. Notification Templates (dim_notification_templates) — NEU v1.1

| template_name | trigger_event | channel | priority |
|--------------|---------------|---------|----------|
| reminder_due | system.reminder_due | in-app | High |
| reminder_overdue | system.reminder_overdue | push | Urgent |
| process_stage_changed | process.stage_changed | in-app | Medium |
| ai_suggestion_ready | match.suggestion_ready | in-app | Low |
| document_parsed | document.cv_parsed | in-app | Low |
| dead_letter_alert | system.dead_letter_alert | push | Urgent |
| circuit_breaker_tripped | system.circuit_breaker_tripped | push | Urgent |
| candidate_datenschutz | candidate.datenschutz_requested | push | Urgent |
| scrape_change | scrape.change_detected | in-app | Medium |
| placement_success | process.placed | in-app | High |

---

## 24. Prompt Templates (dim_prompt_templates) — NEU v1.1

| template_name | activity_type | provider | version |
|--------------|---------------|----------|---------|
| cv_parsing_v1 | CV-Parsing | anthropic | 1 |
| call_summary_v1 | Call-Zusammenfassung | anthropic | 1 |
| candidate_classification_v1 | Generalist/Spezialist | openai | 1 |
| seniority_classification_v1 | Seniority-Einstufung | openai | 1 |
| dossier_generation_v1 | Dossier-Generierung | anthropic | 1 |
| action_items_extraction_v1 | Action Items | anthropic | 1 |
| red_flag_detection_v1 | Red Flags | anthropic | 1 |

**Hinweis:** Prompt-Inhalte (system_prompt, user_prompt_template) werden separat gepflegt und versioniert. Diese Tabelle definiert nur die Metadaten.

---

## 25. AI Write Policies (dim_ai_write_policies) — NEU v1.1

| entity_type | field_name | policy_type | review_required | Begründung |
|------------|------------|-------------|-----------------|-----------|
| candidate | candidate_stage | suggest_only | true | Stage ist kritisch – immer Mensch |
| candidate | is_do_not_contact | forbidden | true | AI darf das nie setzen |
| candidate | * | suggest_only | true | Default: alle Kandidaten-Felder nur Vorschlag |
| history | ai_summary | auto_allowed | false | Dediziertes AI-Feld |
| history | ai_action_items | auto_allowed | false | Dediziertes AI-Feld |
| history | ai_red_flags | auto_allowed | false | Dediziertes AI-Feld |
| process | current_process_stage | suggest_only | true | Stage-Änderung immer durch Mensch |
| process | * | suggest_only | true | Default: alle Prozess-Felder nur Vorschlag |

---

## 26. PII-Klassifikation (dim_pii_classification) — NEU v1.1

| table_name | field_name | pii_level | requires_masking |
|-----------|------------|-----------|------------------|
| dim_candidates_profile | first_name | direct_identifying | true |
| dim_candidates_profile | last_name | direct_identifying | true |
| dim_candidates_profile | email_1 | direct_identifying | true |
| dim_candidates_profile | email_2 | direct_identifying | true |
| dim_candidates_profile | phone_mobile | direct_identifying | true |
| dim_candidates_profile | phone_direct | direct_identifying | true |
| dim_candidates_profile | phone_private | direct_identifying | true |
| dim_candidates_profile | adresse | direct_identifying | true |
| dim_candidates_profile | birth_date | highly_sensitive | true |
| dim_candidates_profile | linkedin_url | direct_identifying | true |
| dim_candidates_profile | photo_url | direct_identifying | true |
| fact_candidate_briefing | briefing_salary_currently | highly_sensitive | true |
| fact_candidate_briefing | briefing_salary_ziel | highly_sensitive | true |
| fact_candidate_briefing | briefing_salary_schmerzgrenze | highly_sensitive | true |
| fact_history | transcript_text | highly_sensitive | true |
| fact_history | email_body_html | sensitive_business | true |
| dim_account_contacts | email_1 | direct_identifying | true |
| dim_account_contacts | phone_mobile | direct_identifying | true |
| fact_process_finance | salary_candidate_target | highly_sensitive | true |
| fact_process_finance | salary_client_budget | sensitive_business | true |
| fact_process_finance | fee_amount | sensitive_business | true |

---

## 27. Datenqualitätsregeln (dim_quality_rule_types) — NEU v1.1

| rule_name | rule_category | entity_type | affected_field | auto_fixable |
|-----------|--------------|-------------|----------------|-------------|
| email_missing | completeness | candidate | email_1 | false |
| phone_missing | completeness | candidate | phone_mobile | false |
| no_contact_12_months | validity | candidate | last_contacted_date | false |
| potential_duplicate | uniqueness | candidate | — | false |
| salary_missing_in_briefing | completeness | candidate | briefing_salary_currently | false |
| account_domain_missing | completeness | account | domain_normalized | false |
| account_no_contact | validity | account | last_contacted_date | false |
| process_stale_30_days | validity | process | updated_at | true |
| mandate_no_research | completeness | mandate | — | false |

---

## 28. Naming Convention — NEU v1.1

```text
Schweizer Fachbegriffe bleiben auf Deutsch:
  ansprache, wohnort, arbeitsort, kuendigungsfrist,
  briefing_kandidatenbewertung, Bauführer, Polier,
  Deviseur, Bauleiter, Gebäudetechnikplaner etc.

Generische/technische Felder sind auf Englisch:
  candidate_stage, phone_mobile, is_do_not_contact,
  email_1, is_active, created_at, row_version etc.

Begründung: Domänenspezifische Begriffe aus dem Schweizer Bau-/RE-Sektor
haben keine sinnvolle englische Übersetzung. Einheitliches Englisch würde
zu Missverständnissen bei den Recruitern führen.

Umlaute: ä, ö, ü werden in Anzeigenamen verwendet (nie ß, immer ss).
DB-Feldnamen: keine Umlaute (z.B. kuendigungsfrist statt kündigungsfrist).
```

---

## 29. Email-Templates (dim_email_templates) — NEU v1.2

> 32 Standard-Templates. Erweiterbar über Admin → Settings.
> Templates mit linked_activity_type setzen den Activity-Type automatisch (kein AI nötig).
> Templates mit linked_automation_key triggern Backend-Automationen.

| # | Template-Key | Name | Kategorie | Automation | Linked Activity-Type |
|---|---|---|---|---|---|
| 1 | sourcing_erstansprache | Erstansprache Kandidat | Sourcing | — | Emailverkehr - Allgemeine Kommunikation |
| 2 | sourcing_followup | Follow-up Erstansprache | Sourcing | — | Emailverkehr - Allgemeine Kommunikation |
| 3 | sourcing_linkedin_inmail | LinkedIn InMail Vorlage | Sourcing | — | Messaging - LinkedIn |
| 4 | cv_chase | CV Nachfassen | CV & Dokumente | — | Emailverkehr - CV Chase |
| 5 | doc_chase | Dokumente Nachfassen | CV & Dokumente | — | Emailverkehr - Allgemeine Kommunikation |
| 6 | cv_danke | CV Eingangsbestätigung | CV & Dokumente | — | Emailverkehr - Eingangsbestätigung Bewerbung |
| 7 | briefing_einladung | Briefing-Termin vereinbaren | Briefing | — | Emailverkehr - Allgemeine Kommunikation |
| 8 | briefing_erinnerung | Briefing-Termin Erinnerung | Briefing | — | Emailverkehr - Allgemeine Kommunikation |
| 9 | briefing_absage_kandidat | Absage Briefing bestätigen | Briefing | — | Emailverkehr - Absage Briefing |
| 10 | go_muendliche_versand | Mündliche GOs versenden | GO-Prozess | ⚡ jobbasket.is_oral_go + mandate_research → go_muendlich | Emailverkehr - Mündliche GOs versendet |
| 11 | go_absage_vor_termin | Absage vor GO-Termin | GO-Prozess | — | Emailverkehr - Absage vor GO Termin |
| 12 | go_absage_nach_termin | Absage nach GO-Termin | GO-Prozess | — | Emailverkehr - Absage nach GO Termin |
| 13 | cv_versand_kunde | CV Versand an Kunden | Versand | ⚡ process.created + jobbasket → cv_sent | Emailverkehr - Allgemeine Kommunikation |
| 14 | expose_versand_kunde | Exposé Versand an Kunden | Versand | ⚡ process.created + jobbasket → expose_sent | Emailverkehr - Allgemeine Kommunikation |
| 15 | bewerbung_absage_kunde | Absage Bewerbung (von Kunde) | Versand | — | Emailverkehr - Absage Bewerbung |
| 16 | interview_einladung | Interview-Einladung | Interview | — | Emailverkehr - Allgemeine Kommunikation |
| 17 | interview_bestaetigung | Interview-Bestätigung | Interview | — | Emailverkehr - Allgemeine Kommunikation |
| 18 | interview_vorbereitung | Interview-Vorbereitung | Interview | — | Emailverkehr - Allgemeine Kommunikation |
| 19 | interview_absage_kandidat | Interview-Absage an Kandidat | Interview | — | Emailverkehr - Absage Bewerbung |
| 20 | offer_begleitung | Offer-Begleitung | Placement | — | Emailverkehr - Allgemeine Kommunikation |
| 21 | placement_gratulation | Gratulation Placement | Placement | — | Emailverkehr - Allgemeine Kommunikation |
| 22 | onboarding_info | Onboarding-Informationen | Placement | — | Emailverkehr - Allgemeine Kommunikation |
| 23 | probezeit_checkin | Probezeit Check-in | Placement | — | Emailverkehr - Allgemeine Kommunikation |
| 24 | mandat_statusreport | Mandat Status-Report | Mandate | — | Emailverkehr - Mandatskommunikation |
| 25 | mandat_kickoff | Mandat Kickoff-Bestätigung | Mandate | — | Emailverkehr - Mandatskommunikation |
| 26 | agb_versand | AGB Versand | Mandate | — | Emailverkehr - AGB Verhandlungen |
| 27 | mandatshunt_erstansprache | Mandatshunt Erstansprache | Mandate | — | Emailverkehr - Allgemeine Kommunikation |
| 28 | assessment_link | Assessment-Link versenden | Assessment | ⚡ Invite-Status → sent | Assessment - Link versendet |
| 29 | assessment_erinnerung | Assessment Erinnerung | Assessment | — | Emailverkehr - Allgemeine Kommunikation |
| 30 | assessment_ergebnis_kunde | Assessment-Ergebnisse an Kunden | Assessment | — | Emailverkehr - Mandatskommunikation |
| 31 | allgemein_blanko | Freie Email (kein Template) | Allgemein | — | AI-Vorschlag |
| 32 | refresh_kontakt | Refresh-Kontakt | Allgemein | — | Emailverkehr - Allgemeine Kommunikation |

**Platzhalter-Variablen:** `{{kandidat_vorname}}`, `{{kandidat_nachname}}`, `{{kandidat_name}}`, `{{account_name}}`, `{{job_titel}}`, `{{mandat_name}}`, `{{sparte}}`, `{{datum}}`, `{{start_datum}}`, `{{consultant_vorname}}`, `{{consultant_nachname}}`, `{{consultant_telefon}}`, `{{consultant_email}}`, `{{signatur}}`, `{{fehlende_dokumente}}`, `{{preleads_liste}}`

---

## 30. Jobbasket-Ablehnungsgründe (dim_jobbasket_rejection_types) — NEU v1.2

> Ablehnungsgründe für Preleads, unterteilt nach Verursacher (candidate/cm/am)

| Grund | Kategorie | Beschreibung |
|-------|-----------|-------------|
| Nicht interessiert | candidate | Kandidat möchte dieses Unternehmen nicht verfolgen |
| Bereits dort beworben | candidate | Kandidat hat sich bereits selbst beworben |
| Schlechte Erfahrung | candidate | Kandidat hat negative Erfahrung mit dem Unternehmen |
| Zu weit weg | candidate | Arbeitsweg/Standort nicht akzeptabel |
| Gehalt zu tief | candidate | Gehaltsangebot unter Schmerzgrenze |
| Kein Interesse an Branche | candidate | Branche des Unternehmens uninteressant |
| Nicht passend (Profil) | cm | CM-Einschätzung: Kandidat passt nicht |
| Kein offenes Mandat | cm | Kein aktives Mandat bei diesem Account |
| Bereits genug Kandidaten | cm | Account hat genug Kandidaten im Prozess |
| Account aktuell gesperrt | am | AM hat Account für Vorschläge gesperrt |
| Hiring Freeze | am | Account hat Einstellungsstopp |
| Andere Priorität | am | AM möchte andere Kandidaten priorisieren |

---

## 31. Automation-Settings (dim_automation_settings) — NEU v1.2

> Konfigurierbare Fristen und Schwellwerte. Pro Tenant individuell einstellbar.

| Setting-Key | Default | Typ | Beschreibung |
|---|---|---|---|
| ghosting_frist_tage | 14 | int | Tage nach Mündliche GOs ohne Reaktion → GO Ghosting |
| stale_prozess_tage | 14 | int | Tage in gleicher Process-Stage → Stale markieren |
| inactive_alter | 60 | int | Alter ab dem Kandidat automatisch Inactive wird |
| datenschutz_reset_tage | 365 | int | Tage nach Datenschutz-Stage → automatisch Refresh |
| briefing_reminder_tage | 7 | int | Tage nach Erstellung ohne Briefing → Reminder |
| klassifizierung_eskalation_1h | 24 | int | Stunden bis Stufe 1 Eskalation (Reminder) |
| klassifizierung_eskalation_2h | 48 | int | Stunden bis Stufe 2 Eskalation (Head_of) |
| cold_inactive_monate | 6 | int | Monate mit Temperature Cold → Inactive |
| onboarding_reminder_tage | 7 | int | Tage vor Startdatum → Onboarding Call Reminder |
| post_placement_checkin_1 | 30 | int | Tage nach Placement → 1. Check-in |
| post_placement_checkin_2 | 60 | int | Tage nach Placement → 2. Check-in |
| post_placement_checkin_3 | 90 | int | Tage nach Placement → 3. Check-in |
| data_retention_warnung_tage | 30 | int | Tage vor Anonymisierung → Admin-Warnung |
| klassifizierung_ziel_pct | 95 | int | Ziel-Klassifizierungsrate in Prozent |
| interview_datum_reminder_tage | 2 | int | Tage nach Stage-Wechsel ohne Interview-Datum → Reminder an CM |

---

# TEIL B: Neue Stammdaten v1.3 (ergänzt 2026-04-14)

---

## 51. Assessment-Typen (dim_assessment_types)

Typ-Katalog für das Credits-basierte Assessment-Auftragsmodell. Ein Auftrag kann gemischte Typen enthalten (z.B. 1× MDI + 1× Relief + 1× ASSESS 5.0). Umwidmung nur innerhalb gleichen Typs.

| ID | Type-Key | Display-Name | Partner | Default-Dauer (min) | Notizen |
|-----|----------|-------------|---------|---------------------|---------|
| at_001 | mdi | Management-Dimensions-Inventory (MDI) | SCHEELEN | 60 | Persönlichkeits-/Führungsanalyse |
| at_002 | relief | Relief | SCHEELEN | 45 | Belastungs-/Stress-Analyse |
| at_003 | assess_5_0 | ASSESS 5.0 | ASSESS 5.0 | 75 | Arbeitsverhalten / Skills |
| at_004 | disc | DISC-Test | SCHEELEN | 30 | Verhaltensprofile |
| at_005 | eq | EQ Test | SCHEELEN | 45 | Emotionale Intelligenz |
| at_006 | scheelen_6hm | Scheelen 6 Human Needs | SCHEELEN | 30 | Motivations-Analyse |
| at_007 | driving_forces | Driving Forces | TTI | 40 | Motivatoren-Analyse |
| at_008 | human_needs | Human Needs / BIP | SCHEELEN | 60 | Bedürfnis-Struktur |
| at_009 | ikigai | Ikigai | intern | 60 | Sinn-/Purpose-Analyse |
| at_010 | ai_analyse | AI-Analyse | intern | — | AI-generiertes Profil aus CRM-Daten |
| at_011 | teamrad_session | Teamrad-Session | intern | 90 | Team-Persönlichkeits-Session |

**Schema:** `id`, `type_key` UNIQUE, `display_name`, `partner`, `default_duration_minutes`, `is_active`, `sort_order`.

---

## 52. Prozess-interne Ablehnungsgründe (dim_rejection_reasons_internal)

Bei `fact_process_core.rejected_by = 'internal'`.

| ID | Grund |
|-----|-------|
| rri_01 | Mandat gekündigt |
| rri_02 | Kandidat wurde anderweitig platziert (Konkurrenz) |
| rri_03 | Mandats-Position wurde vom Kunden zurückgezogen |
| rri_04 | Interne Einschätzung: Match doch nicht passend |
| rri_05 | Fachliche Qualifikation reicht nicht |
| rri_06 | Gehaltsvorstellung zu weit auseinander |
| rri_07 | Kulturfit unklar / negativ |
| rri_08 | Zeitliche Verfügbarkeit nicht kompatibel |
| rri_09 | Location/Pendelradius-Konflikt |
| rri_10 | Doppelbesetzung (Kandidat anderweitig im Prozess) |
| rri_11 | Sonstiges |

---

## 53. Honorar-Staffel (dim_honorar_settings)

Erfolgsbasis-Staffel aus AGB. Pro Prozess überschreibbar via `honorar_override_pct`.

| ID | Gehaltsbereich | Prozentsatz |
|-----|----------------|-------------|
| hs_01 | < CHF 90'000 | 21% |
| hs_02 | CHF 90'000 – 109'999 | 23% |
| hs_03 | CHF 110'000 – 129'999 | 25% |
| hs_04 | ≥ CHF 130'000 | 27% |

**Ab 2027 geplant:** 23/25/27/29%. Gesteuert via `honorar_staffel_valid_from` Tenant-Setting.

---

## 54. Kultur-Analyse-Dimensionen (dim_culture_dimensions)

6 Dimensionen für Arkadium-Kultur-Analyse auf Account- und Firmengruppen-Ebene.

| ID | Dimension | Low-End | High-End |
|-----|-----------|---------|----------|
| cd_01 | Leistungsorientierung | entspannt, prozessorientiert | performanceorientiert, ambitioniert |
| cd_02 | Innovationskultur | konservativ, bewährt | disruptiv, experimentell |
| cd_03 | Autonomiespielraum | direktiv, zentralisiert | eigenverantwortlich, dezentral |
| cd_04 | Feedbackkultur | hierarchisch, sparsam | offen, 360° |
| cd_05 | Hierarchieflachheit | vertikal, stark strukturiert | flach, kollegial |
| cd_06 | Transformationsreife | stabilitätsorientiert | veränderungsfreudig |

Scores 0–100 pro Dimension, Gesamt-Kulturfit-Score als gewichtete Summe.

---

## 55. SIA-Phasen (dim_sia_phases)

SIA-Norm 112 — 6 Haupt-Phasen + 12 Teilphasen hierarchisch.

| ID | SIA-Nr. | Name | Parent | Level |
|-----|---------|------|--------|-------|
| sia_01 | 1 | Strategische Planung | — | 1 |
| sia_02 | 11 | Bedürfnisformulierung | sia_01 | 2 |
| sia_03 | 12 | Lösungsstrategien | sia_01 | 2 |
| sia_04 | 2 | Vorstudien | — | 1 |
| sia_05 | 21 | Projektdefinition / Machbarkeitsstudie | sia_04 | 2 |
| sia_06 | 22 | Auswahlverfahren | sia_04 | 2 |
| sia_07 | 3 | Projektierung | — | 1 |
| sia_08 | 31 | Vorprojekt | sia_07 | 2 |
| sia_09 | 32 | Bauprojekt | sia_07 | 2 |
| sia_10 | 33 | Bewilligungsverfahren | sia_07 | 2 |
| sia_11 | 4 | Ausschreibung | — | 1 |
| sia_12 | 41 | Ausschreibung / Vergleich / Antrag | sia_11 | 2 |
| sia_13 | 5 | Realisierung | — | 1 |
| sia_14 | 51 | Ausführungsprojekt | sia_13 | 2 |
| sia_15 | 52 | Ausführung | sia_13 | 2 |
| sia_16 | 53 | Inbetriebnahme / Abschluss | sia_13 | 2 |
| sia_17 | 6 | Bewirtschaftung | — | 1 |
| sia_18 | 62 | Betrieb | sia_17 | 2 |

**Schema:** `id`, `sia_number` VARCHAR, `name`, `parent_phase_id` self-FK NULL, `level` SMALLINT (1 oder 2).

Multi-Select in Projekt- und Kandidaten-Beteiligungs-Drawern.

---

## 56. Prozess-Drop-Gründe (dim_dropped_reasons)

Gründe warum ein Prozess nie zustande kam (Status `Dropped`, nicht zu verwechseln mit `Rejected`).

| ID | Grund |
|-----|-------|
| dr_01 | Kunde hat Prozess nicht gestartet (keine Rückmeldung nach CV-Versand) |
| dr_02 | Kandidat hat sich nicht zurückgemeldet (Kontakt abgebrochen) |
| dr_03 | Technischer Fehler beim Versand (Email-Bounce, etc.) |
| dr_04 | Kunde hat CV zurückgewiesen ohne Prozess-Eröffnung |
| dr_05 | Mandat wurde vor Prozess-Start gekündigt |
| dr_06 | Sonstiges |

---

## 57. Cancellation-Gründe (dim_cancellation_reasons)

Nur bei Prozess-Status `Cancelled` — Rückzieher nach Placement-Zusage.

| ID | Grund | Seite |
|-----|-------|-------|
| cr_01 | Kandidat nimmt Gegenangebot des aktuellen Arbeitgebers an | Kandidat |
| cr_02 | Kandidat hat alternatives Angebot angenommen | Kandidat |
| cr_03 | Kandidat persönliche Gründe (familiär, gesundheitlich) | Kandidat |
| cr_04 | Kunde zieht Position zurück (interne Restrukturierung) | Kunde |
| cr_05 | Kunde zieht Position zurück (Budget-Freeze) | Kunde |
| cr_06 | Relocation gescheitert | Kandidat |
| cr_07 | Visa / Arbeitserlaubnis-Probleme | Kandidat |
| cr_08 | Kulturfit-Probleme nach Vertragsprüfung | beidseitig |
| cr_09 | Sonstiges | — |

100% Rückvergütung greift bei Status = Cancelled.

---

## 58. Angebots-Ablehnungs-Gründe (dim_offer_refused_reasons)

Bei Prozess-Stage `Angebot` wenn Kandidat ablehnt (vor Vertragsunterzeichnung).

| ID | Grund |
|-----|-------|
| orr_01 | Gehalts-Angebot unter Erwartungen |
| orr_02 | Benefits/Konditionen nicht attraktiv |
| orr_03 | Startdatum / Kündigungsfrist passt nicht |
| orr_04 | Standort / Pendelaufwand doch zu hoch |
| orr_05 | Rolle / Verantwortung anders als erwartet |
| orr_06 | Unternehmens-Eindruck nach Interviews negativ |
| orr_07 | Alternativ-Angebot bekommen |
| orr_08 | Aktueller Arbeitgeber hat Gegenangebot gemacht |
| orr_09 | Persönliche Gründe |
| orr_10 | Sonstiges |

---

## 59. Vakanz-Rejection-Gründe (dim_vacancy_rejection_reasons)

Wenn AM einen Scraper-Vorschlag (`fact_jobs.status='scraper_proposal'`) ablehnt.

| ID | Grund |
|-----|-------|
| vrr_01 | Stelle ist bereits intern besetzt / nicht mehr aktiv |
| vrr_02 | Nicht im Arkadium-Marktsegment (falsche Sparte) |
| vrr_03 | Account ist Blacklisted / No-Hunt |
| vrr_04 | Duplicate-Detection fehlgeschlagen (bereits als anderer Job im System) |
| vrr_05 | Scraper-Extraktion fehlerhaft (unvollständige Daten) |
| vrr_06 | Stelle ist nur für interne Bewerber |
| vrr_07 | Temp- / Aushilfs-Position (nicht Arkadium-Scope) |
| vrr_08 | Sonstiges |

---

## 60. Scraper-Typen (dim_scraper_types)

Scraper-Registry.

| ID | Type-Key | Display-Name | Implementation | Default-Intervall (h) | Rate-Limit (/h) | Phase |
|-----|----------|-------------|----------------|----------------------|-----------------|-------|
| st_01 | team_page | Team-Page (Kontakte) | Spezialisiert | 24 | 10 | 1 |
| st_02 | career_page | Career-Page (Vakanzen) | Spezialisiert | 12 | 15 | 1 |
| st_03 | impressum_agb | Impressum / AGB | Generisch + AI | 168 | 5 | 1 |
| st_04 | linkedin_job_change | LinkedIn Job-Wechsel | Spezialisiert | 24 | API-Limit | 2 |
| st_05 | external_jobboards | Externe Jobboards (jobs.ch, alpha.ch) | Spezialisiert | 6 | 30 | 1 |
| st_06 | pr_reports | Geschäftsberichte / Presse | Generisch + AI | 2160 | 2 | 1 |
| st_07 | handelsregister | Handelsregister (Zefix API) | Spezialisiert | 720 | 50/d | 1 |

---

## 61. Scraper-Global-Settings (dim_scraper_global_settings)

| Key | Default | Typ | Beschreibung |
|-----|---------|-----|-------------|
| auto_accept_confidence_threshold | NULL | decimal | NULL = manuell immer |
| error_retry_max | 3 | int | Max Retries bei Fehler |
| n_strike_disable_threshold | 5 | int | N Fehler in Folge → Auto-Disable |
| hot_account_factor | 0.5 | decimal | Intervall-Multiplikator Hot |
| warm_account_factor | 1.0 | decimal | Intervall-Multiplikator Warm |
| cold_account_factor | 2.0 | decimal | Intervall-Multiplikator Cold |
| class_a_factor | 0.75 | decimal | Class A |
| class_c_factor | 1.25 | decimal | Class C |
| concurrent_run_limit | 10 | int | Max parallele Runs |
| rate_limit_alert_threshold | 0.5 | decimal | > 50% Token/h → Alert |
| bulk_parallelism_default | 5 | int | Default Bulk-Scrape |
| low_confidence_threshold | 0.6 | decimal | Findings unter Schwelle → `needs_am_review` |
| group_uid_match_high_threshold | 0.85 | decimal | Firmengruppen-Auto-Suggestion |
| group_uid_match_medium_threshold | 0.6 | decimal | Firmengruppen-Review-Schwelle |

---

## 62. Matching-Gewichte Job-Kandidat (dim_matching_weights)

| Key | Default | Beschreibung |
|-----|---------|-------------|
| w_sparte | 0.15 | Sparte-Match |
| w_function | 0.20 | Function-Match |
| w_salary | 0.15 | Salary-Range-Match |
| w_location | 0.10 | Location/Radius |
| w_skills | 0.20 | Skills inkl. Hard-Skills-Gate |
| w_availability | 0.10 | Verfügbarkeit / Temperatur |
| w_experience | 0.10 | Erfahrungs-Match |
| default_threshold | 0.60 | Score-Schwelle |

Summe der Gewichte = 1.0.

---

## 63. Matching-Gewichte Projekt-Kandidat (dim_matching_weights_project)

| Key | Default | Beschreibung |
|-----|---------|-------------|
| w_cluster | 0.25 | Cluster-Überlappung |
| w_bkp | 0.25 | BKP-Gewerk-Erfahrung |
| w_sia | 0.15 | SIA-Phasen-Abdeckung |
| w_volume | 0.10 | Volumen-Ähnlichkeit |
| w_location | 0.10 | Geografie-Proximität |
| w_recency | 0.15 | Recency-Bonus |

---

## 64. Reminder-Vorlagen (dim_reminder_templates)

| ID | Template-Key | Text | Trigger | Empfänger |
|-----|-------------|------|---------|-----------|
| rt_01 | onboarding_call | Onboarding-Call mit {candidate_name} vor Arbeitsantritt | start_date − 7d | CM |
| rt_02 | placement_1m | 1-Monats-Check mit {candidate_name} | placed_at + 1 Monat | CM |
| rt_03 | placement_2m | 2-Monats-Check mit {candidate_name} | placed_at + 2 Monate | CM |
| rt_04 | placement_3m | 3-Monats-Check = Garantie-Ende mit {candidate_name} | placed_at + 3 Monate | CM + AM |
| rt_05 | guarantee_end | Garantiefrist endet — Prozess schliessen | placed_at + garantie_months | AM + CM |
| rt_06 | interview_coaching | Coaching-Call vor Interview mit {candidate_name} | scheduled_at − 2d | CM |
| rt_07 | interview_debriefing | Debriefing nach Interview | scheduled_at (Abend) | CM |
| rt_08 | interview_date_missing | Interview-Datum fehlt für {process_id} | stage_changed_at + 2d | CM |
| rt_09 | briefing_missing | Briefing für {candidate_name} fehlt | created_at + 7d | CM |
| rt_10 | info_request_auto_extend | Schutzfrist Info-Request: noch {days} Tage bis Auto-Extension | info_requested_at + daily | AM |

Placeholder-Tokens: {candidate_name}, {process_id}, {days}, {account_name}, {mandate_name}.

---

## 65. Time-Mandat-Pakete (dim_time_packages)

| ID | Paket | Slots | Preis/Slot/Woche (CHF) | Listenpreis (CHF) |
|-----|-------|-------|------------------------|-------------------|
| tp_01 | Entry | 2 | 1'950 | 2'250 |
| tp_02 | Medium | 3 | 1'650 | 1'950 |
| tp_03 | Professional | 4 | 1'250 | 1'650 |

Min. 2 Slots, keine Mindestlaufzeit, 3 Wochen schriftliche Kündigung.

---

## 66. Automation-Settings-Erweiterungen (dim_automation_settings v1.3)

Neue Schlüssel zusätzlich zur bestehenden Tabelle (v1.2 Sektion 50).

### Prozess-Stale-Detection (pro Stage, JSONB)

| Key | Default | Typ | Beschreibung |
|-----|---------|-----|-------------|
| process_stale_thresholds | `{"expose":14,"cv_sent":14,"ti":7,"interview_1":14,"interview_2":14,"interview_3":14,"assessment":21,"angebot":10}` | jsonb | Tage pro Stage bis `Stale` |

### Temperature-Schwellen

| Key | Default | Typ |
|-----|---------|-----|
| candidate_temperature_hot_threshold | 5 | int |
| candidate_temperature_warm_threshold | 1 | int |
| account_temperature_hot_threshold | 5 | int |
| account_temperature_warm_threshold | 1 | int |

### Schutzfrist

| Key | Default | Typ |
|-----|---------|-----|
| protection_window_base_months | 12 | int |
| protection_window_extend_months | 4 | int |
| protection_window_info_request_wait_days | 10 | int |

### Assessment-Billing

| Key | Default | Typ |
|-----|---------|-----|
| assessment_billing_overdue_check_hour | "02:00" | varchar |
| assessment_payment_terms_days | 30 | int |

### Prozess-Garantie und Batch-Hours

| Key | Default | Typ |
|-----|---------|-----|
| process_guarantee_closer_check_hour | "01:00" | varchar |
| process_stale_detection_hour | "03:00" | varchar |

### Referral

| Key | Default | Typ |
|-----|---------|-----|
| referral_amount_chf | 1000 | int |
| referral_candidate_payout_offset_days | 90 | int |

### Matching-Recompute

| Key | Default | Typ |
|-----|---------|-----|
| matching_daily_batch_hour | "04:00" | varchar |

---

## 67. Assessment-Dimensionen-Kataloge (NEU 14.04.2026)

Feingranulare Dimensionen pro Assessment-Typ. Diese Dimensionen werden in den Kandidaten-Assessment-Sub-Tabs und im Account-Teamrad verwendet.

### 67a. EQ-Dimensionen (`dim_eq_dimensions`) — Scheelen / Insights MDI (Goleman-Modell)

5 Dimensionen gemäss **TriMetrix EQ Musterbericht (Scheelen/Insights MDI)** — nicht EQ-i 2.0.

| ID | Dimension | Kategorie |
|-----|-----------|-----------|
| eq_1 | Selbstwahrnehmung | Intrapersonal |
| eq_2 | Selbstregulierung | Intrapersonal |
| eq_3 | Motivation | Intrapersonal |
| eq_4 | Soziale Wahrnehmung (Empathie) | Interpersonal |
| eq_5 | Soziale Regulierung (Soziale Kompetenz) | Interpersonal |

Skala 0–100 pro Dimension + **Emotionaler Intelligenzquotient insgesamt** (Mittelwert) + separat `Intrapersonal` (Mittel aus 1+2+3) + `Interpersonal` (Mittel aus 4+5).

### 67b. Motivatoren-Dimensionen (`dim_motivator_dimensions`) — TTI 12 Driving Forces (Spranger-6)

Basiert auf **Eduard Spranger 6 Haupttypen**, erweitert von TTI Success Insights zu **12 Driving Forces** (je 2 Pole pro Kategorie). Quelle: TriMetrix EQ Musterbericht S. 25, 28–32.

| ID | Kategorie | L-Pol (Driving Force) | R-Pol (Driving Force) |
|-----|-----------|-------|-------|
| mot_1 | Theoretisch | Instinktiv | Intellektuell |
| mot_2 | Ökonomisch | Idealistisch | Effizienzgetrieben |
| mot_3 | Ästhetisch | Objektiv | Harmonisch |
| mot_4 | Sozial | Eigennützig | Altruistisch |
| mot_5 | Individualistisch | Kooperativ | Machtorientiert |
| mot_6 | Traditionell | Aufgeschlossen | Prinzipientreu |

Skala 0–100 pro Pol. Die 4 höchsten Werte bilden die **primäre Gruppe** ("P"), die mittleren 4 die **situative Gruppe** ("S"), die 4 niedrigsten die **indifferente Gruppe** ("I"). Primäre Motivatoren bestimmen das Handeln unabhängig von der Situation.

### 67c. ASSESS-5.0-Kompetenzen (`dim_assess_competencies`)

26 Kompetenzen gemäss ASSESS by SCHEELEN®. Skala 1–10. Basis für ASSESS 5.0-Assessment (intern synonym genutzt).

```
Ergebnisorientierung · Qualitätsfokus · Problemlösung · Entscheidungsfindung
Planungs- & Organisationsfähigkeit · Teamarbeit · Kommunikationsfähigkeit · Konfliktmanagement
Kundenorientierung · Beziehungsmanagement & Netzwerkaufbau · Mitarbeiterentwicklung
Strategisches Denken · Überzeugungskraft · Veränderungsmanagement · Anpassungsfähigkeit
Innovationsfähigkeit · Lernagilität · Unternehmerisches Handeln · Digitale Befähigung
Führung · Selbstreflexion · Selbstmanagement · Resilienz · Integrität
Fachliche Entwicklung · Diversitätskompetenz
```

### 67d. ASSESS-Standard-Profile (`dim_assess_standard_profiles`)

11 Standard-Profile (Subset der 26 Kompetenzen, gewichtet). Custom-Profile sind ebenfalls erstellbar (`is_custom=true` pro Tenant).

| ID | Profil |
|-----|--------|
| sp_01 | Geschäftsführung / Executive |
| sp_02 | HR Manager |
| sp_03 | Personalleiter |
| sp_04 | Abteilungsleiter |
| sp_05 | Teamleiter |
| sp_06 | Specialist |
| sp_07 | Sales Manager |
| sp_08 | Sales Professional |
| sp_09 | Leading Leaders |
| sp_10 | Leading Others |
| sp_11 | Leading Yourself |

Welche Kompetenzen zu welchem Profil gehören: `bridge_profile_competencies (profile_id, competency_id, weight)`. Standard-Profile sind read-only; Custom-Profile editierbar pro Tenant.

---

---

## 56. Dok-Generator-Templates (dim_document_templates) — NEU 2026-04-17

Template-Katalog für globalen Dok-Generator `/operations/dok-generator`. Ein Template = eine Dokument-Variante (Du/Sie + Rabatt/Mandat-Typ = separate Templates, nicht Parameter — User-Entscheidung 2026-04-17).

**Phase-1-Scope:** 38 aktive Templates, 1 ausstehend (`mandat_offerte_time` mit `is_active=false`). Weitere Assessment-Typen (DISC/6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad) sind im Katalog aktiv, aber Mockup filtert Phase-1 auf SCHEELEN-Produkte.

### 56.1 Template-Katalog (38 + 1 ausstehend)

#### Mandat-Offerten (Offerte = Vertrag, gleiches Dokument)

| ID | Template-Key | Display-Name | Kinds | Multi | Source-DOCX |
|-----|--------------|-------------|-------|-------|-------------|
| dt_001 | `mandat_offerte_target` | Mandat-Offerte Target | mandate | — | General/4_Account Management/Mandatsofferte/Vorlage_Mandatsofferte.docx |
| dt_002 | `mandat_offerte_taskforce` | Mandat-Offerte Taskforce | mandate | — | (abgeleitet) |
| dt_003 | `mandat_offerte_time` | Mandat-Offerte Time | mandate | — | **🟡 is_active=false** (ausstehend) |
| dt_004 | `auftragserteilung_optionale_stage` | Auftragserteilung Optionale Stage | mandate | — | Vorlage_Auftragserteilung Optionale Stage_VIII.docx |

#### Mandat-Rechnungen (Du/Sie separat)

| ID | Template-Key | Display-Name | Kinds | Bulk |
|-----|--------------|-------------|-------|------|
| dt_005 | `rechnung_mandat_teilzahlung_1_sie` | Rechnung Mandat · T1 · Sie | mandate | ✓ |
| dt_006 | `rechnung_mandat_teilzahlung_1_du` | Rechnung Mandat · T1 · Du | mandate | ✓ |
| dt_007 | `rechnung_mandat_teilzahlung_2_sie` | Rechnung Mandat · T2 · Sie | mandate | ✓ |
| dt_008 | `rechnung_mandat_teilzahlung_2_du` | Rechnung Mandat · T2 · Du | mandate | ✓ |
| dt_009 | `rechnung_mandat_teilzahlung_3_sie` | Rechnung Mandat · T3 · Sie | mandate | ✓ |
| dt_010 | `rechnung_mandat_teilzahlung_3_du` | Rechnung Mandat · T3 · Du | mandate | ✓ |
| dt_011 | `rechnung_mandat_optionale_stage` | Rechnung Optionale Stage | mandate | — |
| dt_012 | `rechnung_mandat_kuendigung` | Rechnung Kündigung Mandat | mandate | — |
| dt_013 | `mahnung_mandat_sie` | Mahnung Mandat · Sie | rechnung | ✓ |
| dt_014 | `mahnung_mandat_du` | Mahnung Mandat · Du | rechnung | ✓ |

#### Best-Effort-Rechnungen (Du/Sie + mit/ohne Rabatt separat)

| ID | Template-Key | Display-Name | Kinds | Bulk |
|-----|--------------|-------------|-------|------|
| dt_015 | `rechnung_best_effort_sie` | Rechnung Erfolgsbasis · Sie | process | ✓ |
| dt_016 | `rechnung_best_effort_du` | Rechnung Erfolgsbasis · Du | process | ✓ |
| dt_017 | `rechnung_best_effort_mit_rabatt_sie` | Rechnung Erfolgsbasis mit Rabatt · Sie | process | ✓ |
| dt_018 | `rechnung_best_effort_mit_rabatt_du` | Rechnung Erfolgsbasis mit Rabatt · Du | process | ✓ |
| dt_019 | `mahnung_best_effort_sie` | Mahnung Erfolgsbasis · Sie | rechnung | ✓ |
| dt_020 | `mahnung_best_effort_du` | Mahnung Erfolgsbasis · Du | rechnung | ✓ |
| dt_021 | `mahnung_best_effort_mit_rabatt_sie` | Mahnung Erfolgsbasis mit Rabatt · Sie | rechnung | ✓ |
| dt_022 | `mahnung_best_effort_mit_rabatt_du` | Mahnung Erfolgsbasis mit Rabatt · Du | rechnung | ✓ |

#### Assessment

| ID | Template-Key | Display-Name | Kinds |
|-----|--------------|-------------|-------|
| dt_023 | `assessment_offerte` | Offerte Diagnostik & Assessment | assessment_order |
| dt_024 | `assessment_rechnung` | Rechnung Diagnostik & Assessment | assessment_order |
| dt_025 | `executive_report` | Executive Report (NEU) | assessment_run |

#### Rückerstattung

| ID | Template-Key | Display-Name | Kinds |
|-----|--------------|-------------|-------|
| dt_026 | `rechnung_rueckerstattung` | Rechnung Rückerstattung | process |

#### Kandidat (migriert aus Kandidat-Tab-9)

| ID | Template-Key | Display-Name | Kinds | Multi |
|-----|--------------|-------------|-------|-------|
| dt_027 | `ark_cv` | ARK CV | candidate | — |
| dt_028 | `abstract` | Abstract | candidate | — |
| dt_029 | `expose` | Exposé (anonymisiert) | candidate + mandate | ✓ |
| dt_030 | `referenzauskunft` | Referenzauskunft | candidate | — |
| dt_031 | `referral_schreiben` | Referral-Schreiben | candidate | — |

#### Reportings

| ID | Template-Key | Display-Name | Kinds |
|-----|--------------|-------------|-------|
| dt_032 | `am_reporting` | AM Reporting Fokus | tenant |
| dt_033 | `cm_reporting` | CM Reporting Fokus | mitarbeiter |
| dt_034 | `monatsreporting_cm` | Monatsreporting CM | mitarbeiter |
| dt_035 | `reporting_hunt` | Reporting Hunt | mandate |
| dt_036 | `reporting_team_leader` | Reporting Team Leader | tenant |
| dt_037 | `mandat_report` | Mandat-Status-Report an Kunde | mandate |
| dt_038 | `factsheet_personalgewinnung` | Factsheet Personalgewinnung | account |

**Total: 38 Phase-1-Templates** (+ dt_003 `mandat_offerte_time` ausstehend).

### 56.2 Kategorien (für Sidebar-Filter)

- `mandat_offerte` (4 Templates)
- `mandat_rechnung` (10)
- `best_effort` (8)
- `assessment` (3)
- `rueckerstattung` (1)
- `kandidat` (5)
- `reporting` (7)

### 56.3 Entity-Kinds (für Entity-Picker-Filter)

9 Kinds: `mandate` · `rechnung` · `process` · `assessment_order` · `assessment_run` · `candidate` · `account` · `mitarbeiter` · `tenant`.

### 56.4 Parameter

- `sprache` (de/en — en Phase 2 via LLM)
- `empfaenger_anrede` (Herr/Frau/Team/Gleichgestellt)
- `rechnung_zahlungsfrist_tage` (14/30)

**Entschieden gegen Parameter (stattdessen eigene Templates):**
- Du/Sie (ganzer Text unterscheidet sich)
- Mit/ohne Rabatt (Best-Effort)
- Mandat-Typ Target/Taskforce/Time (eigene Offerten-Templates)

### 56.5 Schema

Siehe `ARK_DATABASE_SCHEMA_v1_3.md` (v1.4 Erweiterung) neue Tabelle `dim_document_templates` + `fact_documents` Erweiterungen.

### 56.6 RPO-Offerte nicht Teil des Dok-Generators

RPO ist separate Dienstleistung mit eigenem Prozess-Flow — kein Template im Dok-Generator-Katalog (User-Entscheidung 2026-04-17).

---

## Anhang: Bezug zu Detailseiten-Specs

| Stammdaten | Verwendet in Spec |
|------------|-------------------|
| **dim_document_templates** (neu 2026-04-17) | ARK_DOK_GENERATOR_SCHEMA_v0_1 + INTERACTIONS_v0_1 |
| dim_assessment_types | ARK_ASSESSMENT_DETAILMASKE_SCHEMA_v0_3 |
| dim_rejection_reasons_internal | ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1 (Rejection) + ARK_MANDAT_DETAILMASKE_INTERACTIONS_v0_3 (Bulk-Reject bei Kündigung) |
| dim_honorar_settings | ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1 TEIL 6 |
| dim_culture_dimensions | ARK_ACCOUNT_DETAILMASKE_INTERACTIONS_v0_3 TEIL 3 + ARK_FIRMENGRUPPE_DETAILMASKE_INTERACTIONS_v0_1 TEIL 3 |
| dim_sia_phases | ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1 + Kandidatenmaske Werdegang |
| dim_dropped_reasons | ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1 |
| dim_cancellation_reasons | ARK_PROZESS_DETAILMASKE_INTERACTIONS_v0_1 TEIL 2 |
| dim_offer_refused_reasons | Prozess-Stage Angebot |
| dim_vacancy_rejection_reasons | ARK_JOB_DETAILMASKE_INTERACTIONS_v0_1 TEIL 1 |
| dim_scraper_types + dim_scraper_global_settings | ARK_SCRAPER_MODUL_SCHEMA_v0_1 TEIL 4 |
| dim_matching_weights | ARK_JOB_DETAILMASKE_SCHEMA_v0_1 Tab 3 |
| dim_matching_weights_project | ARK_PROJEKT_DETAILMASKE_SCHEMA_v0_1 Tab 3 |
| dim_reminder_templates | Alle Detailseiten mit Auto-Reminder-Triggern |
| dim_time_packages | ARK_MANDAT_DETAILMASKE_SCHEMA_v0_2 Time-Konditionen |
| dim_eq_dimensions | Kandidat Assessment EQ + Account Teamrad §V |
| dim_motivator_dimensions | Kandidat Assessment Motivatoren + Account Teamrad §IV |
| dim_assess_competencies + dim_assess_standard_profiles | Kandidat Assessment ASSESS 5.0 + Account Teamrad §VI |
| **dim_absence_type** (neu 2026-04-19 · v1.4) | ARK_ZEIT_SCHEMA_v0_1 + ARK_ZEIT_INTERACTIONS_v0_1 |
| **dim_time_category** (neu 2026-04-19 · v1.4) | ARK_ZEIT_SCHEMA_v0_1 |
| **dim_work_time_model** (neu 2026-04-19 · v1.4) | ARK_ZEIT_SCHEMA_v0_1 |
| **dim_salary_continuation_scale** (neu 2026-04-19 · v1.4) | ARK_ZEIT_SCHEMA_v0_1 |
| **fact_holiday_cantonal** Seeds (neu 2026-04-19 · v1.4) | ARK_ZEIT_SCHEMA_v0_1 |

---

## 90. Zeit-Modul-Stammdaten (Phase 3 ERP · v1.4 · 2026-04-19)

**Quellen:** `specs/ARK_ZEIT_SCHEMA_v0_1.md` · `wiki/sources/hr-reglemente.md` (Tempus Passio 365 · Generalis Provisio · Locus Extra) · `wiki/meta/zeit-decisions-2026-04-19.md`

**Legal-Basis:** ArG Art. 9/12/15/46 · ArGV 1 Art. 73/73b · OR Art. 321c/324a/329a · revDSG Art. 5 · BGE 4A_227/2017

### 90.1 `dim_absence_type` (30 Codes)

**Kategorien:**
- **medical:** SICK_PAID · SICK_UNPAID · ACCIDENT_OCC · ACCIDENT_NOCC
- **civic:** MILITARY · CIVIL_SERVICE · CIVIL_PROTECTION · FIREFIGHTER · REDCROSS · OFFICIAL_DUTY
- **family:** MATERNITY (16 Wo) · OTHER_PARENT (10 AT) · ADOPTION (10 AT) · CARE_RELATIVE · CARE_CHILD_LONG
- **policy:** VACATION · VACATION_HALF_AM · VACATION_HALF_PM · COMP_TIME · UNPAID_LEAVE · BEREAVEMENT · WEDDING · MOVE · EDUCATION_PAID · SABBATICAL
- **extra:** EXTRA_BIRTHDAY_SELF (1 T/J) · EXTRA_BIRTHDAY_CLOSE (1 T/J) · EXTRA_JOKER (1 T/J) · EXTRA_ZEG (1 T je Halbjahr bei ≥100%) · EXTRA_GL (bis 3 T)

**DJ-gestaffelte Arztzeugnis-Schwelle** (Reglement §3.5.2): 1.DJ→Tag 1 · 2.DJ→Tag 2 · 3+DJ→Tag 3.

### 90.2 `dim_time_category` (12 Codes)

PROD_BILL · PROD_NONBILL · CLIENT_MEETING · CANDIDATE_MEETING · RESEARCH · BD_SALES · TEAM_DEV · ADMIN · INTERNAL_MEETING · TRAINING · TRAVEL_WORK · BREAK.

**ZEG-relevant** (für Commission-Engine): PROD_BILL · PROD_NONBILL · CLIENT_MEETING · CANDIDATE_MEETING · RESEARCH.

### 90.3 `dim_work_time_model` (5 Codes)

FLEX_CORE (Default · Gleitzeit mit Kernzeit) · FIXED · PARTTIME · SIMPLIFIED_73B (ArGV 1 Art. 73b · schriftliche Vereinbarung) · EXEMPT_EXEC (höhere leitende Tätigkeit · enge Legal-Prüfung).

### 90.4 Kernzeiten (Reglement Tempus Passio 365 §2)

- Mo–Fr 08:45–12:00
- Mo–Do 13:30–17:45
- Fr 13:30–16:00
- Fr 15:30–18:00: 2.5h Team-/Persönlichkeitsentwicklung (aggregierbar, zählt zur 45h-Normalarbeitszeit)

### 90.5 Normalarbeitszeit

**45h/Woche** (Reglement Tempus Passio §2 · entspricht gesetzlicher Höchstarbeitszeit ArG Art. 9). Teilzeit pro-rata via `variant_percent`.

### 90.6 `dim_salary_continuation_scale` (Zürcher + Berner)

Default laut Reglement Generalis Provisio §6.2.1 = **Zürcher Skala**. Alternative: Berner / Basler / INSURANCE_EQUIV.

**Zürcher Skala (nach 3 Mt Dienstzeit):**

| DJ | Dauer |
|----|-------|
| 1 | 3 Wo |
| 2 | 8 Wo |
| 3 | 9 Wo |
| 4 | 10 Wo |
| 5–9 | 11 Wo |
| 10–14 | 16 Wo |
| 15–19 | 21 Wo |
| 20–24 | 26 Wo |
| ab 25 | 31 Wo |

### 90.7 `fact_holiday_cantonal` ZH 2026 Seeds (12 Einträge)

**9 gesetzliche Feiertage** (ArG 20a):
- 01.01. Neujahr · 03.04. Karfreitag · 06.04. Ostermontag · 01.05. Tag der Arbeit · 14.05. Auffahrt · 25.05. Pfingstmontag · 01.08. Bundesfeier (Sa) · 25.12. Weihnachten · 26.12. Stephanstag (Sa)

**1 Reglement-bezahlter Nicht-Gesetzlicher** (Tempus Passio): 02.01. Berchtoldstag

**2 Sperrfrist-Halbtage** (Reglement Sperrfristen für Extra-Guthaben, nicht statutory): 20.04. Sechseläuten PM · 14.09. Knabenschiessen PM

**WICHTIG:** Berchtoldstag + Sechseläuten + Knabenschiessen sind in ZH **nicht gesetzlich**. Reglement behandelt Berchtoldstag als bezahlten Feiertag (Firmenpolicy), die zwei Halbtage nur als Sperrfristen. `fact_holiday_cantonal.is_statutory` Flag unterscheidet.

### 90.8 `firm_settings` (19 Keys)

| Key | Default | Quelle |
|-----|---------|--------|
| max_daily_hours | 10.0 | F7 Peter-Decision |
| normal_weekly_hours | 45.0 | Reglement §2 |
| team_dev_weekly_hours | 2.5 | Reglement §2 |
| default_break_threshold_5h | 15 | ArG + Reglement |
| default_break_threshold_7h | 30 | ArG + Reglement |
| default_break_threshold_9h | 60 | ArG + Reglement |
| vacation_default_days | 25 | Reglement §2 |
| vacation_carryover_deadline_rule | 14d_after_easter | Reglement §2 |
| doctor_cert_1dj/2dj/3dj_plus | 1 / 2 / 3 | Reglement §3.5.2 |
| salary_continuation_scale_default | ZURICH | Reglement §6.2.1 |
| salary_continuation_waiting_period_months | 3 | Reglement §6.2.1 |
| monthly_payroll_cutoff_day | 25 | Tempus Passio |
| extra_leave_birthday_days | 1 | Reglement §2 |
| extra_leave_birthday_close_days | 1 | Reglement §2 |
| extra_leave_joker_days | 1 | Reglement §2 |
| extra_leave_zeg_days_per_halfyear | 1 | Reglement §2 |
| extra_leave_gl_max_days | 3 | Reglement §2 |
| jahres_ueberzeit_cap | 170 | ArG Art. 12 |
| overtime_compensation_policy | paid_with_salary | **Arkadium-Policy**: Überstunden + Überzeit mit Grundlohn abgegolten · keine Kompensation/Auszahlung · Tracking nur für Compliance (ArG-Cap). Alternative Values für andere Tenants: `time_off` (nur Zeitausgleich) · `pay_25pct` (25% Zuschlag Auszahlung) · `hybrid` (MA-Wahl) |

### 90.9 Scanner-Integration (Fingerabdruck)

**F4-Decision:** Pausen manuell via Fingerabdruck-Scanner (Scan-Out/Scan-In). `fact_time_scan_event` speichert Roh-Scans, Worker aggregiert nightly zu `fact_time_entry`.

**DSG-Risk:** Biometrische Daten (Template-Hash) = besondere Personendaten nach Art. 5 Ziff. 4 revDSG. DSFA vor Go-Live · Opt-out-Alternative (Badge/PIN) · Zweckbindung + Audit-Log `fact_scanner_access_audit`.

---

## Version-Changelog

- **v1.3 (2026-04-17):** dim_document_templates + RPO-Offerte-Exklusion
- **v1.4 (2026-04-19):** Zeit-Modul-Stammdaten (§90) · 30 Abwesenheitstypen · 12 Zeit-Kategorien · 5 Arbeitszeit-Modelle · ZH-Feiertage 2026 · Zürcher/Berner Skala · Scanner-Integration · 19 firm_settings
- **v1.5 (2026-04-24):** Activity-Types-Patch (§91) + E-Learning-Modul Sub A/B/C/D (§92-§95). 18 → 19 Activity-Kategorien (+`elearning`). +37 Activity-Types Activity-Patch (#70-#106) + 40 E-Learning Activity-Types (#107-#146). Neue Kataloge `dim_event_types` (~113 Rows) + `fact_system_log` (15 Ops-Events). 25 neue E-Learning-Enums. UI-Label-Vocabulary für `wiki/meta/mockup-baseline.md §16`.

---

# TEIL C (§91) — Activity-Types-Patch v1.3 → v1.4 (2026-04-17)

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md`
**Basis-Spec:** `specs/ARK_SYSTEM_ACTIVITY_TYPES_SCHEMA_v1.md`
**Decisions:** `specs/ARK_SYSTEM_ACTIVITY_TYPES_DECISIONS_v1_3.md`

## §91.1 Neue Kategorien-Liste (ersetzt „11 Kategorien" im Header)

```
18 Kategorien (vor E-Learning):
 1 Kontaktberührung       2 Erreicht             3 Emailverkehr
 4 Messaging              5 Interviewprozess     6 Placementprozess
 7 Refresh Kandidatenpflege  8 Mandatsakquise   9 Erfolgsbasis
10 Assessment            11 System / Meta       12 Kalender & Planung (NEU v1.4)
13 Dokumenten-Pipeline (NEU v1.4)  14 Garantie & Schutzfrist (NEU v1.4)
15 Scraper & Intelligence (NEU v1.4)  16 Pipeline-Transitions (NEU v1.4)
17 Saga-Events (NEU v1.4)     18 AI & LLM (NEU v1.4)
```

## §91.2 Neue Spalten `dim_activity_types`

```
actor_type:     user | system | automation | integration
source_system:  threecx | outlook | gmail | scraper | llm | saga-engine |
                nightly-batch | event-worker | manual-upload | calendar-integration
is_notifiable:  true = In-App-Notification beim Process-Owner / false = stumm
```

## §91.3 Row-Ergänzungen in bestehenden Sektionen (4 neue Rows)

| # | Activity Type | Kategorie | Kanal | actor_type | source_system | is_notifiable |
|---|---|---|---|---|---|---|
| 103 | Emailverkehr - Bounce | Emailverkehr | Email | integration | outlook | false |
| 104 | Assessment - Credit verbraucht | Assessment | System | automation | event-worker | false |
| 105 | Placementprozess - Referral ausgelöst | Placementprozess | System | automation | saga-engine | true |
| 106 | System - Kandidat anonymisiert (GDPR) | System / Meta | System | automation | nightly-batch | false |

## §91.4 Neue Kategorie-Blöcke (33 Rows #70-#102)

**Kalender & Planung (3):** #70 Interview geplant · #71 Reminder Interview bevor · #72 Reminder Interview-Datum fehlt

**Dokumenten-Pipeline (5):** #73 Hochgeladen · #74 CV automatisch geparst · #75 OCR abgeschlossen · #76 Vektorindex aufgenommen · #77 Neu geparst

**Garantie & Schutzfrist (7):** #78 Garantiefrist gestartet · #79 Garantiefrist erfüllt · #80 Garantiefrist gebrochen · #81 Reminder Garantie läuft ab · #82 Schutzfrist gestartet · #83 Schutzfrist auf 16 Mt verlängert · #84 Schutzfrist Claim eröffnet

**Scraper & Intelligence (6):** #85 Neue Person bei Account · #86 Person hat Account verlassen · #87 Neue Job-Stelle erkannt · #88 Rollenänderung erkannt · #89 Eintrag importiert · #90 Schutzfrist-Match erkannt

**Pipeline-Transitions Auto (8):** #91 Jobbasket Mündliches GO · #92 Schriftliches GO · #93 Zuweisung abgeschlossen · #94 Versandbereit · #95 CV an Kunde versendet · #96 Stage automatisch gewechselt · #97 Stale erkannt · #98 Automatisch abgelehnt

**Saga-Events (1):** #99 Placement Vollständig abgeschlossen (Saga V7 · Sub-Drawer mit V1-V6 aus `fact_system_log`)

**AI & LLM (3):** #100 Briefing aus Transkript befüllt · #101 Call-Transkription fertig · #102 Activity-Type-Vorschlag

Vollständige Seed-Daten (alle Spalten inkl. Beschreibung): siehe `specs/ARK_STAMMDATEN_PATCH_v1_3_to_v1_4_ACTIVITY_TYPES.md §Neue Sektionen`.

## §91.5 Statistik-Block (neu berechnet)

```
Total Activity-Types:           106  (+37 v1.4 System-Activities)
  davon is_auto_logged = true:   38
  davon is_auto_logged = false:  68
Kategorien:                      18  (11 v1.3 + 7 neue)

actor_type-Verteilung:
  user          ~68    automation    ~24
  integration   ~10    system         ~4

entity_relevance-Verteilung:
  candidate-only: ~52   account-only: ~22   both: ~32

source_system-Verteilung (nur actor_type <> 'user'):
  event-worker ~13 · nightly-batch ~8 · saga-engine ~5
  scraper ~6 · llm ~4 · outlook ~1 · calendar-integration ~1
```

## §91.6 §14c NEU — `dim_event_types` (Event-Katalog ~61 Rows)

Mapping Event-Name → Activity-Type (oder `fact_system_log`). Domänen-Übersicht:

| event_domain | # Events | Beispiel |
|--------------|----------|----------|
| candidate | 2 | `candidate.stage_changed` |
| process | 4 | `process.stage_changed`, `process.stale_detected`, `process.auto_rejected`, `process.placement_completed` |
| jobbasket | 5 | `jobbasket.go_oral`, `jobbasket.cv_sent` |
| guarantee | 4 | `guarantee.started`, `guarantee.breached` |
| protection_window | 3 | `protection_window.started`, `direct_hire_claim.opened` |
| scrape | 6 | `scrape.new_person`, `scrape.role_changed` |
| document | 5 | `document.uploaded`, `document.cv_parsed` |
| email | 3 | `email.sent`, `email.received`, `email.bounced` |
| call | 2 | `call.transcript_ready`, `call.missed` |
| assessment | 3 | `assessment.link_sent`, `assessment.credit_consumed` |
| ai | 3 | `briefing.auto_filled`, `history.classification_suggested` |
| saga | 8 | `saga.v1_stage_placement` … `saga.failure` |
| system | 7 | `temperature.updated`, `circuit_breaker.tripped` |
| reminder | 3 | `reminder.interview_upcoming`, `reminder.guarantee_expiring` |
| finance | 2 | `finance.calculation_triggered`, `finance.refund_calculated` |
| referral | 1 | `referral.triggered` |

**Total ~61 Event-Types** — 46 → `fact_history` (via Activity-Type-Mapping), 15 → `fact_system_log` (Ops-only).

## §91.7 §14d NEU — `fact_system_log` (15 Ops-only Events)

Keine `dim_activity_types`-Row. `target_table='fact_system_log'`, nur in Admin-Debug-Tab (`/admin/system-log`):

| event_name | severity | emitter |
|-----------|----------|---------|
| `saga.v1_stage_placement` | info | saga-engine |
| `saga.v2_finance_calculated` | info | saga-engine |
| `saga.v3_job_filled` | info | saga-engine |
| `saga.v4_guarantee_opened` | info | saga-engine |
| `saga.v5_referral_triggered` | info | saga-engine |
| `saga.v6_staffing_plan_updated` | info | saga-engine |
| `saga.failure` | error | saga-engine |
| `temperature.updated` | debug | nightly-scoring-batch |
| `matching.scores_recomputed` | debug | matching-recompute-worker |
| `staffing_plan.updated` | info | project-staffing-worker |
| `webhook.triggered` | info | webhook-dispatcher |
| `dead_letter.alert` | error | event-queue-monitor |
| `process.duplicate_detected` | warn | process-creation-guard |
| `circuit_breaker.tripped` | critical | automation-engine |
| `retention.warning` | warn | gdpr-retention-batch |

**Retention:** 180 Tage Prod / 30 Tage Test / 7 Tage Dev. Key: `dim_automation_settings.system_log_retention_days`.

---

# TEIL D (§92) — E-Learning Sub A · Kurs-Katalog (v0.1 → 2026-04-24)

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_v0_1.md`
**Basis-Specs:** `specs/ARK_E_LEARNING_SUB_A_SCHEMA_v0_1.md`, `…_INTERACTIONS_v0_1.md`

## §92.1 Neue Activity-Category `elearning` (19. Kategorie)

**CHECK-Erweiterung `dim_activity_types.activity_category`:**

```sql
ALTER TABLE dim_activity_types DROP CONSTRAINT IF EXISTS dim_activity_types_activity_category_check;
ALTER TABLE dim_activity_types ADD CONSTRAINT dim_activity_types_activity_category_check
  CHECK (activity_category IN (
    'Kontaktberührung','Erreicht','Emailverkehr','Messaging',
    'Interviewprozess','Placementprozess','Refresh Kandidatenpflege',
    'Mandatsakquise','Erfolgsbasis','Assessment','System',
    'Kalender & Planung','Dokumenten-Pipeline','Garantie & Schutzfrist',
    'Scraper & Intelligence','Pipeline-Transitions','Saga-Events','AI & LLM',
    'elearning'  -- NEU v1.5
  ));
```

**CHECK-Erweiterung `dim_event_types.event_category`:** `+'elearning'`.

## §92.2 Neue Enums Sub A (8)

**`elearn_assignment_reason`** (5): `onboarding` · `adhoc` · `refresher` · `role_change` · `sparten_change`

**`elearn_assignment_status`** (4): `active` · `completed` · `expired` · `cancelled`

**`elearn_attempt_kind`** (3): `module` · `pretest` · `newsletter` (`newsletter` ab Sub C aktiv)

**`elearn_attempt_status`** (3): `in_progress` · `pending_review` · `finalized`

**`elearn_review_status`** (4): `pending` · `confirmed` · `overridden` · `confirmed_auto`

**`elearn_question_type`** (6): `mc` · `multi` · `freitext` · `truefalse` · `zuordnung` · `reihenfolge`

**`elearn_course_status`** (3): `draft` · `published` · `archived`

**`elearn_badge_type`** (4 Initial, erweiterbar): `first_course` · `all_onboarding` · `sparte_expert` · `streak_7`

## §92.3 Activity-Types-Seed Sub A (11 Rows #107-#117)

| # | activity_type_name | activity_category | activity_channel | is_auto_loggable |
|---|---|---|---|---|
| 107 | elearn_assigned | elearning | CRM | true |
| 108 | elearn_started | elearning | CRM | true |
| 109 | elearn_completed | elearning | CRM | true |
| 110 | elearn_quiz_passed | elearning | CRM | true |
| 111 | elearn_quiz_failed | elearning | CRM | true |
| 112 | elearn_cert | elearning | System | true |
| 113 | elearn_badge | elearning | System | true |
| 114 | elearn_refresher | elearning | System | true |
| 115 | elearn_role_change | elearning | System | true |
| 116 | elearn_expired | elearning | System | true |
| 117 | elearn_onboarding_done | elearning | CRM | true |

## §92.4 Event-Types-Seed Sub A (16 Rows)

| event_name | create_history | default_activity_type |
|---|---|---|
| `elearn_course_assigned` | true | elearn_assigned |
| `elearn_course_started` | true | elearn_started |
| `elearn_course_completed` | true | elearn_completed |
| `elearn_lesson_completed` | false | — |
| `elearn_quiz_attempted` | false | — |
| `elearn_quiz_passed` | true | elearn_quiz_passed |
| `elearn_quiz_failed` | true | elearn_quiz_failed |
| `elearn_freitext_submitted` | false | — |
| `elearn_freitext_reviewed` | false | — |
| `elearn_certificate_issued` | true | elearn_cert |
| `elearn_badge_earned` | true | elearn_badge |
| `elearn_refresher_triggered` | true | elearn_refresher |
| `elearn_role_change_triggered` | true | elearn_role_change |
| `elearn_assignment_expired` | true | elearn_expired |
| `elearn_onboarding_finalized` | true | elearn_onboarding_done |
| `elearn_content_imported` | false | — |

## §92.5 UI-Label-Vocabulary Sub A

Kanonische Mappings (für `wiki/meta/mockup-baseline.md §16`):

| Enum-Wert | UI-Label (DE) |
|---|---|
| `assignment_reason=onboarding` | Onboarding |
| `assignment_reason=adhoc` | Einmalige Zuweisung |
| `assignment_reason=refresher` | Refresher |
| `assignment_reason=role_change` | Rollen-Wechsel |
| `assignment_reason=sparten_change` | Sparten-Wechsel |
| `assignment_status=active` | Aktiv |
| `assignment_status=completed` | Abgeschlossen |
| `assignment_status=expired` | Überfällig |
| `assignment_status=cancelled` | Zurückgezogen |
| `attempt_kind=module` | Modul-Quiz |
| `attempt_kind=pretest` | Pre-Test |
| `attempt_kind=newsletter` | Newsletter-Quiz |
| `attempt_status=in_progress` | In Bearbeitung |
| `attempt_status=pending_review` | In Prüfung |
| `attempt_status=finalized` | Ausgewertet |
| `review_status=pending` | Offen |
| `review_status=confirmed` | Bestätigt |
| `review_status=overridden` | Überschrieben |
| `review_status=confirmed_auto` | Automatisch bestätigt |
| `course_status=draft` | Entwurf |
| `course_status=published` | Veröffentlicht |
| `course_status=archived` | Archiviert |
| `badge_type=first_course` | Erster Kurs |
| `badge_type=all_onboarding` | Onboarding-Champion |
| `badge_type=sparte_expert` | Sparten-Experte |
| `badge_type=streak_7` | Lern-Streak (7 Tage) |

---

# TEIL E (§93) — E-Learning Sub B · Content-Generator (v0.1)

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_B_v0_1.md`

## §93.1 Neue Enums Sub B (8)

**`elearn_source_kind`** (5): `pdf` · `docx` · `book` · `web_url` · `crm_query`

**`elearn_source_priority`** (3): `low` · `normal` · `high`

**`elearn_job_status`** (5): `pending` · `running` · `ready_for_review` · `completed` · `failed`

**`elearn_job_triggered_by`** (3): `scheduled` · `manual` · `event`

**`elearn_artifact_type`** (5): `course_meta` · `module` · `lesson` · `quiz_question` · `quiz_pool`

**`elearn_artifact_status`** (5): `draft` · `approved` · `rejected` · `published` · `superseded`

**`elearn_review_action`** (5): `approve` · `reject` · `edit` · `delete` · `publish`

**`elearn_publish_mode`** (2): `direct` · `pr`

## §93.2 Activity-Types-Seed Sub B (10 Rows #118-#127)

| # | activity_type_name | activity_category | activity_channel | is_auto_loggable |
|---|---|---|---|---|
| 118 | elearn_source_registered | elearning | System | true |
| 119 | elearn_source_failed | elearning | System | true |
| 120 | elearn_job_started | elearning | System | true |
| 121 | elearn_job_completed | elearning | System | true |
| 122 | elearn_job_failed | elearning | System | true |
| 123 | elearn_artifact_approved | elearning | CRM | true |
| 124 | elearn_artifact_rejected | elearning | CRM | true |
| 125 | elearn_artifact_edited | elearning | CRM | true |
| 126 | elearn_artifact_published | elearning | System | true |
| 127 | elearn_cost_cap | elearning | System | true |

## §93.3 Event-Types-Seed Sub B (12 Rows)

`elearn_source_registered` · `elearn_source_ingested` · `elearn_source_ingest_failed` · `elearn_generation_job_started` · `elearn_generation_job_completed` · `elearn_generation_job_failed` · `elearn_artifact_created` · `elearn_artifact_approved` · `elearn_artifact_rejected` · `elearn_artifact_edited` · `elearn_artifact_published` · `elearn_cost_cap_exceeded`

## §93.4 UI-Label-Vocabulary Sub B

| Enum-Wert | UI-Label (DE) |
|---|---|
| `source_kind=pdf` | PDF-Dokument |
| `source_kind=docx` | Word-Dokument |
| `source_kind=book` | Buch |
| `source_kind=web_url` | Web-Quelle |
| `source_kind=crm_query` | CRM-Abfrage |
| `source_priority=low/normal/high` | Niedrig / Normal / Hoch |
| `job_status=pending` | Wartet |
| `job_status=running` | Läuft |
| `job_status=ready_for_review` | Zur Prüfung |
| `job_status=completed` | Abgeschlossen |
| `job_status=failed` | Fehler |
| `job_triggered_by=scheduled/manual/event` | Automatisch / Manuell / Ereignis-gesteuert |
| `artifact_type=course_meta/module/lesson/quiz_question/quiz_pool` | Kurs-Metadaten / Modul / Lesson / Quiz-Frage / Quiz-Pool |
| `artifact_status=draft/approved/rejected/published/superseded` | Entwurf / Freigegeben / Abgelehnt / Veröffentlicht / Überholt |
| `review_action=approve/reject/edit/delete/publish` | Freigeben / Ablehnen / Bearbeiten / Löschen / Publizieren |
| `publish_mode=direct/pr` | Direkt-Commit / Pull-Request |

---

# TEIL F (§94) — E-Learning Sub C · Wochen-Newsletter (v0.1)

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_C_v0_1.md`

## §94.1 Neue Enums Sub C (5)

**`elearn_newsletter_section_type`** (6): `market_news` · `crm_insights` · `deep_dive` · `spotlight` · `trend_watch` · `ma_highlight`

**`elearn_newsletter_status`** (4): `draft` · `review` · `published` · `archived`

**`elearn_newsletter_assignment_status`** (6): `pending` · `reading` · `quiz_in_progress` · `quiz_passed` · `quiz_failed` · `expired`

**`elearn_newsletter_subscription_mode`** (3): `auto` · `opt_in` · `opt_out`

**`elearn_newsletter_enforcement_mode`** (2): `soft` · `hard`

**Sub-A-Aktivierung:** `elearn_attempt_kind='newsletter'` ab jetzt produktiv.

## §94.2 Activity-Types-Seed Sub C (9 Rows #128-#136)

| # | activity_type_name | activity_category | activity_channel | is_auto_loggable |
|---|---|---|---|---|
| 128 | elearn_nl_published | elearning | System | true |
| 129 | elearn_nl_assigned | elearning | System | true |
| 130 | elearn_nl_quiz_passed | elearning | CRM | true |
| 131 | elearn_nl_quiz_failed | elearning | CRM | true |
| 132 | elearn_nl_reminder | elearning | System | true |
| 133 | elearn_nl_escalated | elearning | System | true |
| 134 | elearn_nl_expired | elearning | System | true |
| 135 | elearn_nl_override | elearning | CRM | true |
| 136 | elearn_nl_skipped | elearning | System | true |

## §94.3 Event-Types-Seed Sub C (12 Rows)

`elearn_newsletter_issue_drafted` · `elearn_newsletter_issue_published` · `elearn_newsletter_assigned` · `elearn_newsletter_read_started` · `elearn_newsletter_read_completed` · `elearn_newsletter_quiz_passed` · `elearn_newsletter_quiz_failed` · `elearn_newsletter_reminder_sent` · `elearn_newsletter_escalated_to_head` · `elearn_newsletter_expired` · `elearn_newsletter_subscription_added` · `elearn_newsletter_enforcement_override_set`

## §94.4 UI-Label-Vocabulary Sub C

| Enum-Wert | UI-Label (DE) |
|---|---|
| `section_type=market_news` | Markt-News |
| `section_type=crm_insights` | Team-Einblicke |
| `section_type=deep_dive` | Vertiefung |
| `section_type=spotlight` | Im Fokus |
| `section_type=trend_watch` | Trends |
| `section_type=ma_highlight` | Team-Highlight |
| `newsletter_status=draft/review/published/archived` | Entwurf / In Prüfung / Veröffentlicht / Archiviert |
| `nl_assignment_status=pending` | Offen |
| `nl_assignment_status=reading` | Beim Lesen |
| `nl_assignment_status=quiz_in_progress` | Quiz läuft |
| `nl_assignment_status=quiz_passed` | Bestanden |
| `nl_assignment_status=quiz_failed` | Nicht bestanden |
| `nl_assignment_status=expired` | Abgelaufen |
| `subscription_mode=auto` | Automatisch (Pflicht) |
| `subscription_mode=opt_in` | Freiwillig |
| `subscription_mode=opt_out` | Abbestellt |
| `enforcement_mode=soft/hard` | Erinnerungen / Pflicht-Lock |

---

# TEIL G (§95) — E-Learning Sub D · Progress-Gate (v0.1)

**Quelle:** `specs/ARK_STAMMDATEN_PATCH_ELEARNING_SUB_D_v0_1.md`

## §95.1 Neue Enums Sub D (4)

**`elearn_gate_trigger_type`** (5): `newsletter_overdue` · `onboarding_overdue` · `refresher_due` · `cert_expired` · `assignment_expired`

**`elearn_gate_event_action`** (4): `blocked` · `allowed` · `overridden` · `bypassed`

**`elearn_gate_override_type`** (5): `vacation` · `parental_leave` · `medical` · `emergency_bypass` · `other`

**`elearn_cert_status`** (3): `active` · `expired` · `revoked`

## §95.2 `elearn_feature_catalog` (~40 Feature-Keys)

Frei erweiterbar per Code-Deployment · Wildcard-Match erlaubt (`read_*` matcht alle `read_*`-Keys).

| Kategorie | Beispiele |
|---|---|
| write-candidate | `create_candidate`, `update_candidate`, `delete_candidate` |
| write-account | `create_account`, `update_account`, `delete_account` |
| write-mandate | `create_mandate`, `update_mandate`, `delete_mandate` |
| write-job | `create_job`, `update_job`, `delete_job` |
| write-process | `create_process`, `update_process`, `progress_process_stage` |
| write-project | `create_project`, `update_project` |
| write-activity | `create_activity` |
| write-placement | `create_placement` |
| write-email | `send_email` |
| read | `read_candidate`, `read_account`, `read_mandate`, `read_job`, `read_process`, `read_activity`, `read_placement`, `read_admin_*` |
| elearning | `elearning_*` |
| dashboard | `dashboard_full` |
| export | `export_data` |
| admin | `admin_*` |

## §95.3 Activity-Types-Seed Sub D (8 Rows #137-#144)

| # | activity_type_name | activity_category | activity_channel | is_auto_loggable |
|---|---|---|---|---|
| 137 | elearn_gate_blocked | elearning | System | true |
| 138 | elearn_gate_overridden | elearning | System | true |
| 139 | elearn_gate_override_created | elearning | CRM | true |
| 140 | elearn_gate_override_ended | elearning | CRM | true |
| 141 | elearn_cert_expired | elearning | System | true |
| 142 | elearn_cert_revoked | elearning | System | true |
| 143 | elearn_course_major_version | elearning | System | true |
| 144 | elearn_compliance_low | elearning | System | true |

## §95.4 Event-Types-Seed Sub D (12 Rows)

`elearn_gate_rule_created` · `elearn_gate_rule_updated` · `elearn_gate_rule_disabled` · `elearn_gate_blocked` · `elearn_gate_overridden` · `elearn_gate_override_created` · `elearn_gate_override_ended` · `elearn_cert_expired` · `elearn_cert_revoked` · `elearn_course_major_version_bumped` · `elearn_compliance_snapshot_created` · `elearn_login_popup_shown`

## §95.5 UI-Label-Vocabulary Sub D

| Enum-Wert | UI-Label (DE) |
|---|---|
| `gate_trigger_type=newsletter_overdue` | Newsletter offen |
| `gate_trigger_type=onboarding_overdue` | Onboarding überfällig |
| `gate_trigger_type=refresher_due` | Refresher fällig |
| `gate_trigger_type=cert_expired` | Zertifikat abgelaufen |
| `gate_trigger_type=assignment_expired` | Pflicht-Aufgabe abgelaufen |
| `gate_event_action=blocked/allowed/overridden/bypassed` | Blockiert / Erlaubt / Ausnahme aktiv / Notfall-Bypass |
| `override_type=vacation` | Urlaub |
| `override_type=parental_leave` | Elternzeit |
| `override_type=medical` | Krankheit |
| `override_type=emergency_bypass` | Notfall-Bypass |
| `override_type=other` | Sonstiges |
| `cert_status=active/expired/revoked` | Gültig / Abgelaufen / Zurückgenommen |

---

## Statistik nach v1.5

```
Total Activity-Types:  146  (106 v1.4 + 40 E-Learning: 11+10+9+8+2 Sub-B/C/D-only)
Activity-Kategorien:    19  (18 v1.4 + 1 elearning)
E-Learning Enums:       25  (Sub A: 8 · Sub B: 8 · Sub C: 5 · Sub D: 4)
Event-Types gesamt:   ~113  (~61 v1.4 + 52 E-Learning: 16+12+12+12)
```

## Offene Punkte v1.5

- **Refresher-Intervall-Presets:** frei `INT` in MVP; Enum-Vorschlag Phase-2 falls Pflege-Aufwand hoch
- **Badge-Kriterien:** Code-hart in MVP; `dim_elearn_badge_rule` mit JSON-Kriterien Phase-2
- **Sparte-Wert `uebergreifend`:** derzeit Sonder-Wert im Newsletter-Kontext; globaler Sparten-Katalog-Eintrag wenn cross-cutting in anderen Modulen auftaucht

---

## §96 HR-Modul Stammdaten (v1.5-HR, 2026-04-25)

**Spec-Quelle:** `specs/ARK_HR_TOOL_SCHEMA_v0_1.md`

### §96.1 HR-ENUM-Types (10)

| ENUM-Name | Werte (PostgreSQL-Typ) |
|-----------|----------------------|
| `contract_state` | `draft` · `pending_sig` · `active` · `terminated` · `expired` · `voided` |
| `employment_type` | `permanent` · `fixed_term` · `intern` · `freelance` |
| `termination_reason` | `resignation` · `dismissal` · `dismissal_immediate` · `mutual_agreement` · `end_fixed_term` · `retirement` · `death` |
| `hr_doc_state` | `pending` · `signed` · `superseded` · `revoked` |
| `probation_milestone_type` | `month_1_review` · `month_2_review` · `probation_end` · `probation_extended` · `probation_failed` |
| `disciplinary_level` | `verbal_warning` · `written_warning` · `formal_warning` · `final_warning` · `suspension` · `dismissal_immediate` |
| `disciplinary_state` | `draft` · `issued` · `acknowledged` · `disputed` · `resolved` · `archived` |
| `onboarding_state` | `draft` · `active` · `completed` · `overdue` · `cancelled` |
| `onboarding_task_state` | `pending` · `in_progress` · `done` · `skipped` · `overdue` |
| `onboarding_assignee_role` | `new_hire` · `head_of` · `admin` · `it` · `buddy` |

### §96.2 `dim_hr_document_type` (13 Seeds)

HR-Dokument-Typen: Verträge, Reglemente, Bescheinigungen.

| code | label_de | sig | counter_sig | cat | retention_years |
|------|----------|-----|-------------|-----|----------------|
| `EMPLOYMENT_CONTRACT` | Arbeitsvertrag | ✓ | ✓ | vertrag | 10 |
| `GENERALIS_PROVISIO` | Generalis Provisio (Allg. Anstellungsbedingungen) | ✓ | ✓ | reglement | 10 |
| `PROGRESSUS` | Progressus (Stellenbeschreibung) | ✓ | ✓ | vertrag | 10 |
| `PRAEMIUM_VICTORIA` | Praemium Victoria (Provisionsvertrag) | ✓ | ✓ | vertrag | 10 |
| `TEMPUS_PASSIO_365` | Tempus Passio 365 (Arbeitszeitenreglement) | ✓ | ✓ | reglement | 10 |
| `LOCUS_EXTRA` | Locus Extra (Mobiles Arbeiten) | ✓ | ✓ | reglement | 10 |
| `DATENSCHUTZ_ERKLAERUNG` | Datenschutzerklärung (DSG-Einwilligung) | ✓ | ✓ | bescheinigung | 10 |
| `REFERENCE_LETTER` | Arbeitszeugnis | ✓ | ✓ | bescheinigung | 10 |
| `INTERIM_REFERENCE` | Zwischenzeugnis | ✓ | ✓ | bescheinigung | 10 |
| `SALARY_STATEMENT` | Lohnausweis | ✗ | ✗ | bescheinigung | 10 |
| `AHV_CONFIRMATION` | AHV-Bestätigung Anmeldung | ✗ | ✗ | bescheinigung | 5 |
| `PROBATION_EXTENSION` | Probezeit-Verlängerung (OR 335b Abs. 2) | ✓ | ✓ | vertrag | 10 |
| `OTHER` | Sonstiges Dokument | ✗ | ✗ | other | 10 |

> **Hinweis lateinische Eigennamen:** Generalis Provisio / Progressus / Praemium Victoria / Tempus Passio 365 / Locus Extra sind Corporate-Brand-Namen (Latein) — keine Umlaut-Ersetzung.

### §96.3 `dim_disciplinary_offense_type` (13 Seeds)

| code | label_de | category | typical_level |
|------|----------|----------|---------------|
| `REPEATED_LATENESS` | Wiederholte Unpünktlichkeit | attendance | written_warning |
| `UNEXCUSED_ABSENCE` | Unentschuldigtes Fernbleiben | attendance | written_warning |
| `INSUBORDINATION` | Nichtbefolgung von Weisungen | conduct | written_warning |
| `MISCONDUCT_COLLEAGUE` | Unangemessenes Verhalten gegenüber Kollegen | conduct | verbal_warning |
| `MISCONDUCT_CLIENT` | Unangemessenes Verhalten gegenüber Kunden/Kandidaten | conduct | written_warning |
| `PERFORMANCE_DEFICIENCY` | Wiederholte Leistungsmängel | performance | verbal_warning |
| `TARGET_MISS_REPEATED` | Wiederholtes Verfehlen vereinbarter Ziele | performance | written_warning |
| `DATA_BREACH_INTERNAL` | Verletzung Datenschutz intern | compliance | formal_warning |
| `CONFIDENTIALITY_BREACH` | Bruch der Schweigepflicht (Kunden/Kandidaten) | compliance | formal_warning |
| `EXPENSE_FRAUD` | Manipulation Spesenabrechnung | integrity | final_warning |
| `COMPETITION_VIOLATION` | Verletzung Konkurrenzverbot | integrity | dismissal_immediate |
| `HARASSMENT` | Belästigung / Diskriminierung | conduct | dismissal_immediate |
| `OTHER` | Sonstiger Grund | conduct | verbal_warning |

### §96.4 `dim_onboarding_task_template_type` (18 Seeds)

| code | label_de | assignee | offset_days | mandatory | category |
|------|----------|----------|-------------|-----------|---------|
| `WELCOME_MEETING` | Willkommensgespräch mit Head of | head_of | 1 | ✓ | social |
| `IT_EQUIPMENT_SETUP` | IT-Einrichtung (Laptop, Handy, Zugänge) | it | 1 | ✓ | it |
| `EMAIL_SETUP` | E-Mail + Kalender-Einrichtung (Outlook) | it | 1 | ✓ | it |
| `SIGN_GENERALIS_PROVISIO` | Generalis Provisio unterschreiben | new_hire | 1 | ✓ | compliance |
| `SIGN_PROGRESSUS` | Progressus (Stellenbeschreibung) unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_TEMPUS_PASSIO` | Tempus Passio 365 unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_LOCUS_EXTRA` | Locus Extra unterschreiben | new_hire | 3 | ✓ | compliance |
| `SIGN_PRAEMIUM_VICTORIA` | Praemium Victoria unterschreiben (Provisions-MA) | new_hire | 5 | ✗ | compliance |
| `SIGN_DATENSCHUTZ` | Datenschutzerklärung unterzeichnen | new_hire | 1 | ✓ | compliance |
| `AHV_REGISTRATION` | AHV-Anmeldung Treuhand | admin | 3 | ✓ | admin |
| `BADGE_KEY` | Büroschlüssel / Badge aushändigen | admin | 1 | ✓ | admin |
| `BANK_DETAILS` | Bankverbindung erfassen | new_hire | 3 | ✓ | admin |
| `CRM_INTRO` | CRM-Einführung (ARK CRM Demo) | head_of | 5 | ✓ | role |
| `TOOL_INTRO_ELEARN` | E-Learning Plattform Einführung | head_of | 7 | ✓ | role |
| `BUDDY_INTRO` | Vorstellung Buddy / Paten | buddy | 1 | ✗ | social |
| `TEAM_LUNCH` | Team-Mittagessen (erste Woche) | head_of | 5 | ✗ | social |
| `MONTH_1_REVIEW` | 1-Monats-Feedback-Gespräch | head_of | 30 | ✓ | role |
| `PROBATION_REVIEW` | Probezeit-Abschlussgespräch | head_of | 90 | ✓ | role |

### §96.5 Activity-Types HR-Modul

Das HR-Modul erzeugt keine neuen Activity-Type-Kategorien. HR-Aktionen werden in bestehenden Kategorien §14 erfasst:

| HR-Aktion | Activity-Kategorie |
|-----------|-------------------|
| Vertragsunterzeichnung / Onboarding-Start | System (automatisch) |
| Probezeit-Gespräch | Erfolgsbasis (manuell durch Head) |
| Verwarnung erstellt/zugestellt | System (automatisch) + Erfolgsbasis |
| Kündigung erfasst | System (automatisch) |
| Dokument angefordert / unterschrieben | System (automatisch) |

### §96.6 Statistik nach HR-Modul

```
HR ENUM-Types:         10  (neu in v1.5-HR)
HR Dimension-Tabellen:  3  (dim_hr_document_type · dim_disciplinary_offense_type · dim_onboarding_task_template_type)
HR Fact-Tabellen:       8  (contracts · attachments · disciplinary · probation · templates · template_tasks · instances · instance_tasks)
HR Views:               4  (active_employees · onboarding_progress · disciplinary_summary · pending_signatures)
Tabellen total:       ~215 (204 E-Learning + 11 HR)
```
- **Feature-Catalog-Auto-Discovery:** Script scannt bei jedem Deploy alle `@gate_feature`-Decorators und synct `FEATURE_CATALOG.ts` → Source-of-Truth lebt im Code

---

## §97 Performance-Modul-Stammdaten (v1.6 · 2026-04-25)

**Scope:** Cross-Modul-Analytics-Hub. Liest aus CRM/Billing/Commission/Zeit/E-Learning/HR aggregiert (Snapshot-Layer + Live-Views), schreibt nur in eigene `ark_perf.*`-Tabellen + `dim_dashboard_layout` für User-Custom-Layouts. Vollständiger Patch-Quelltext: `specs/ARK_STAMMDATEN_PATCH_v1_5_to_v1_6_performance.md`.

### §97.1 Neue ENUMs (§F Performance · 11 ENUMs)

- `perf_cadence` — `hourly` · `daily` · `weekly` · `monthly` · `quarterly` · `yearly`
- `anomaly_severity` — `info` · `warn` · `critical` · `blocker`
- `insight_state` — `open` · `acknowledged` · `action_planned` · `resolved` · `false_positive` · `archived`
- `action_item_state` — `pending` · `in_progress` · `done` · `cancelled` · `overdue`
- `outcome_effect` — `improved` · `partially_improved` · `no_change` · `worsened` · `inconclusive`
- `tile_type` — 15 Werte (siehe §97.4)
- `forecast_method` — `markov_stage` · `linear_trend` · `ml_regression` · `manual`
- `metric_aggregation` — `count` · `sum` · `avg` · `median` · `min` · `max` · `p95` · `p99` · `rate` · `ratio` · `ytd` · `mtd` · `wtd`
- `report_cadence` — `on_demand` · `weekly` · `monthly` · `quarterly` · `yearly`
- `report_run_state` — `queued` · `rendering` · `sent` · `failed` · `cancelled`
- `powerbi_view_state` — `fresh` · `stale` · `refreshing` · `failed`

### §97.2 `dim_metric_definition` (~33 Default-Metriken in 7 Kategorien)

| Kategorie | Anzahl | Codes (Auszug) |
|-----------|--------|----------------|
| Pipeline | 8 | `pipeline_velocity_days` · `time_to_hire_days` · `cv_to_placement_rate` · `briefing_to_go_rate` · `interview_to_offer_rate` · `monthly_placements` · `pipeline_value_chf` · `active_processes` |
| Revenue | 6 | `revenue_ytd_chf` · `revenue_mtd_chf` · `commission_run_rate_chf` · `forecast_pipeline_q_chf` · `placement_avg_value_chf` · `mandate_conversion_rate` |
| Coverage | 7 | `candidate_days_since_touch` · `candidate_coverage_score` · `account_days_since_touch` · `account_coverage_score` · `untouched_candidates_count` · `untouched_accounts_count` · `hunt_rate_weekly` |
| Compliance | 5 | `elearn_compliance_pct` · `reminder_backlog_count` · `ai_confirmation_rate` · `unclassified_calls_count` · `agb_pending_accounts` |
| Activity | 4 | `daily_calls_count` · `weekly_meetings_count` · `weekly_briefings_count` · `time_utilization_pct` |
| Forecast | 4 | `forecast_placement_probability` · `forecast_revenue_q_chf` · `goal_achievement_pct` · `goal_drift_pct` |
| Meta | 4 | `snapshot_lag_minutes` · `powerbi_view_stale_count` · `failed_reports_30d` · `data_quality_score` |

Spalten: `code` · `label_de` · `category` · `aggregation` · `unit` · `source_module` · `source_table` · `target_default` · `target_direction` (`higher`/`lower`) · `drill_down` · `cadence_default` · `active`. Admin kann via `/performance/admin/metric-definitions` erweitern.

### §97.3 `dim_anomaly_threshold` (15 Default-Schwellen)

Schwellen-Tupel pro Metric: `info` / `warn` / `critical` / `blocker`. Spalten: `metric_code` · `scope_type` (`global`/`role`/`sparte`/`user`) · `direction` (`above`/`below`) · `window_days` · `min_sample_size` · `cooldown_hours`. Beispiele:
- `candidate_days_since_touch` (above): 14/30/60/120, cooldown 24h
- `account_days_since_touch` (above): 30/60/90/180, cooldown 24h
- `goal_drift_pct` (below): -10/-20/-35/-50, cooldown 24h
- `pipeline_velocity_days` (above): 75/90/120/180, cooldown 168h (1 Wo)
- `elearn_compliance_pct` (role=ma, below): 90/80/70/60, cooldown 168h
- `snapshot_lag_minutes` (above): 30/60/240/1440, cooldown 1h
- `data_quality_score` (below): 95/90/80/70

Sparten-spezifische Overrides (z.B. `account_days_since_touch` für ARC mit anderen Schwellen) per UI nachpflegen.

### §97.4 `dim_dashboard_tile_type` (15 Tile-Types)

`kpi_card` · `kpi_card_compare` · `trend_chart` · `bar_chart` · `funnel` · `heatmap` · `coverage_map` · `goal_progress` · `top_n_list` · `anomaly_list` · `action_list` · `forecast_card` · `cohort_chart` · `sparkline_grid` · `iframe_powerbi`.

Spalten: `code` · `label_de` · `min_w/h` · `default_w/h` · `requires_metric` · `requires_drill_down` · `config_schema_jsonb` (verfügbare Filter pro Tile, z.B. `compare_to: 'previous_period' | 'target' | 'last_year' | 'none'`).

### §97.5 `dim_report_template` (5 Default-Templates)

| code | cadence | audience | cron |
|------|---------|----------|------|
| `weekly_ma_report` | weekly | ma_self | `0 6 * * 1` |
| `weekly_head_report` | weekly | head_team | `0 7 * * 1` |
| `monthly_business_report` | monthly | admin | `0 6 1 * *` |
| `quarterly_exec_report` | quarterly | exec | `0 6 1 1,4,7,10 *` |
| `yearly_review_pack` | yearly | admin | `0 6 1 1 *` (initial inactive) |

`data_bundle_spec_jsonb` definiert Template-spezifisch welche Metriken/Snapshots/Views ins Bundle kommen. Email-Templates (`perf_*_email`) im Email-Modul. **Sender:** Default `dim_user.role_code='admin'` (Nenad), konfigurierbar pro Template.

### §97.6 `dim_powerbi_view` (8 Default-Views)

| code | refresh_cadence | is_critical |
|------|-----------------|-------------|
| `v_perf_pipeline_today` | hourly | TRUE |
| `v_perf_goal_drift_critical` | hourly | TRUE |
| `v_perf_coverage_critical` | hourly | TRUE |
| `v_perf_revenue_monthly` | monthly | FALSE |
| `v_perf_pipeline_funnel_daily` | daily | FALSE |
| `v_perf_cohort_hunt_vintage` | weekly | FALSE |
| `v_perf_activity_heatmap_weekly` | weekly | FALSE |
| `v_perf_elearn_compliance_daily` | daily | FALSE |

`sql_definition` jeder View vollständig im Schema-Patch. **Visibility-Roles:** `{admin}` für alle Power-BI-Views (Power-BI = Admin-Tool). MA-Views direkt via Performance-UI, nicht via Power-BI-Embed.

### §97.7 Erweiterungen bestehender Stammdaten

**§13 `dim_process_stages`** — neue Spalten:
- `funnel_relevance` (`standard` · `major_milestone` · `drop_off_risk` · `terminal`)
- `avg_days_target` (Soll-Verweildauer pro Stage in Tagen, für Stage-Velocity-KPI)

Seeds: `expose=drop_off_risk/5` · `cv_sent=major_milestone/7` · `ti/1st/2nd=drop_off_risk/14` · `3rd=drop_off_risk/21` · `assessment=standard/14` · `offer=major_milestone/7` · `placement=terminal/0`.

**§10 `dim_user`** — neue Spalte:
- `performance_visibility_scope` (`self` · `team` · `tenant` · `admin`)

Seeds: MA/Researcher/CM/AM/RA = `self`, Head = `team`, Admin = `admin`.

**§14 Activity-Types:** keine Änderung — Performance liest `fact_history` aggregiert, Stammdaten unverändert.

### §97.8 Statistik nach Performance-Modul (v1.6 kumulativ)

```
Performance ENUMs:           11
Performance Dimension-Tab.:   6 (dim_metric_definition · dim_anomaly_threshold · dim_dashboard_tile_type · dim_dashboard_layout · dim_report_template · dim_powerbi_view + dim_forecast_conversion_rate)
Performance Fact-Tabellen:   ~10 (fact_metric_snapshot_*hourly/daily/weekly/monthly/quarterly/yearly + fact_perf_goal · fact_insight · fact_action_item · fact_action_outcome · fact_report_run · fact_forecast_snapshot · fact_dashboard_view_log)
Live-Views:                  10 (v_pipeline_funnel · v_candidate_coverage · v_account_coverage · v_mandate_kpi_status · v_revenue_attribution · v_activity_heatmap · v_elearn_compliance · v_zeit_utilization · v_hr_review_summary · v_commission_run_rate)
Materialized Views:           8 (mv_perf_*)
Default-Seeds:               33 Metric-Defs + 15 Anomaly-Thresholds + 15 Tile-Types + 5 Report-Templates + 8 PowerBI-Views = 76 Default-Stammdaten-Rows
Tabellen total:           ~225 (215 v1.5 + 14 ark_perf + 7 ark_hr Performance-Reviews − 3 gestrichen [fact_learning_progress, dim_learning_modules, dim_skill_certifications])
```

### §97.9 Lint-Konformität

- **Stammdaten-Wording:** Alle Labels deutsch. Etablierte Fachterme (KPI, Pipeline, Forecast, Funnel) bleiben englisch.
- **Umlaute:** echte Umlaute (ä ö ü ß) in `label_de`.
- **DB-Tech-Details:** `code`-Spalten technisch (snake_case), `label_de` für UI immer sprechend ("Pipeline-Geschwindigkeit (Tage)", nicht "pipeline_velocity_days").

---

## §98 HR-Performance-Reviews-Stammdaten (v1.6 · 2026-04-25 · Q1=C-Migration)

**Scope:** Q1=C aus Performance-Scoping (2026-04-25). 8 Performance-Schema-Stubs aus DB §19 vollständig ins HR-Modul migriert. Performance-Modul liest read-only via `v_hr_review_summary`. Vollständiger Patch: `specs/ARK_HR_TOOL_SCHEMA_PATCH_v0_1_to_v0_2.md`.

### §98.1 Neue HR-ENUMs (7)

- `review_cycle_cadence` — `quarterly` · `biannual` · `annual` · `probation` · `ad_hoc`
- `review_state` — `draft` · `self_pending` · `manager_pending` · `meeting_scheduled` · `meeting_done` · `signed` · `cancelled`
- `feedback_source_role` — `self` · `manager` · `peer` · `direct_report` · `cross_func` · `external`
- `question_type` — `rating_1_5` · `rating_1_10` · `multi_choice` · `free_text` · `yes_no` · `boolean_explain`
- `competency_level` — `novice`(1) · `developing`(2) · `proficient`(3) · `advanced`(4) · `expert`(5)
- `development_plan_state` — `draft` · `agreed` · `in_progress` · `milestone_due` · `completed` · `archived` · `cancelled`

### §98.2 HR-Tabellen (7 migriert + 0 neu)

Migriert aus DB §19 (vorher Phase-2-Stub) in HR-Modul (`ark_hr.*`):
1. `dim_feedback_cycles` — Review-Zyklen pro Tenant (Quartal/Halbjahr/Jahr/Probation/AdHoc)
2. `dim_feedback_questions` — Question-Bank rolle/sparte-spezifisch
3. `fact_performance_reviews` — Periodische Reviews (Self + Manager + optional 360°-Aggregat)
4. `fact_360_feedback` — Peer/Direct-Reports/Manager/Self-Feedback-Einzelquellen
5. `dim_competency_framework` — Skill-Matrix pro Rolle
6. `fact_competency_ratings` — Skill-Bewertungen pro MA × Competency
7. `fact_development_plans` — Karriere-/Entwicklungspläne

**Gestrichen:** `fact_learning_progress` (E-Learning Sub-A `fact_elearn_attempt` ist Single-Source).

### §98.3 Anti-Sandbagging-Hook

Goals (Performance-Modul `fact_perf_goal`) und HR-Reviews (Manager-Bewertung) sind verknüpft via View `v_hr_review_summary`. Wenn Goals systematisch unterschritten werden bei "advanced/expert"-Bewertung, generiert Anomaly-Detector ein Insight (`severity='warn'`) für Head/Admin. Detail in HR-Patch §11.

### §98.4 Statistik

```
HR-Review-ENUMs:        7
HR-Review-Tabellen:     7 (3 dim + 4 fact)
HR-Review-Views:        1 (v_hr_review_summary, Performance liest)
```


