---
title: "Stammdaten-Digest v1.3.4"
type: meta
created: 2026-04-17
updated: 2026-04-17
sources: ["ARK_STAMMDATEN_EXPORT_v1_3.md"]
tags: [digest, stammdaten, enums, lookup]
---

# Stammdaten-Digest v1.3.4 (Stand 2026-04-17)

Kompakte Referenz zur vollständigen Quelle `C:\ARK CRM\Grundlagen MD\ARK_STAMMDATEN_EXPORT_v1_3.md` (Stand 2026-04-17, v1.2 → v1.3 → v1.3.4 mit neuem §56 Dok-Generator-Templates). **Enum-Werte lossless**, Prosa/Beispiele lossy. Für lange Listen (EDV, Funktionen, Ausbildung, Focus, Cluster) siehe TOC-Hinweis auf Original-§.

---

## TOC — Alle §-Sektionen der Quelle

**TEIL A (v1.2-Bestand):**

| § | Tabelle | Einträge | Status im Digest |
|---|---------|----------|------------------|
| 1 | `dim_edv` — EDV/Software-Skills | 109 Tools in 11 Kategorien | lossy (Kategorien gelistet) |
| 2 | `dim_functions` — Berufsfunktionen | ~190 Einträge in ~25 Kategorien | lossy (Kategorien + Level-Enum) |
| 3 | `dim_education` — Ausbildungen | 503 Einträge | lossy (Levels lossless) |
| 4 | `dim_cluster` — Cluster/Subcluster | ~97 Einträge in 4 Sparten-Gruppen | lossy (Sparte-Gruppierung + Parent-Cluster) |
| 5 | `dim_focus` — Focus/Spezialisierung | ~200 Einträge in ~25 Kategorien | lossy (Kategorien) |
| 6 | `dim_sector` — Branchen/Sektoren | 35 Einträge in 6 Kategorien | **lossless** |
| 7 | `dim_languages` — Sprachen | 20 Einträge | **lossless** |
| 8 | `dim_sparte` — Sparten | 5 Codes | **lossless** |
| 9 | `dim_mitarbeiter` — Mitarbeiter | 10 aktiv | **lossless** |
| 10 | Owner Teams | 2 Teams | **lossless** |
| 10a | `dim_org_functions` — Kontakt-Org-Funktion | 5 Codes | **lossless** |
| 10b | `dim_dossier_preferences` | 7 Codes | **lossless** |
| 10c | `dim_presentation_types` | 3 Codes | **lossless** |
| 11 | Kandidaten-Stages + Wechselmotivation + Temperatur | 8 Stages + 8 Wechsel + 3 Temp | **lossless** |
| 12 | Mandat-Research-Stages + GO-Rejection-Reasons | 13 Stages + 9 Reasons | **lossless** |
| 13 | `dim_process_stages` — Prozess-Stages | 19 Stages (9 Pipeline + 10 Analytics) | **lossless** |
| 13b | `dim_process_status` | 8 Status | **lossless** |
| 14 | `dim_activity_types` — Activity-Types | 69 Einträge in 11 Kategorien | **lossless** |
| 15 | `dim_rejection_reasons_candidate` | 13 Gründe | **lossless** |
| 16 | `dim_rejection_reasons_client` | 16 Gründe | **lossless** |
| 17 | `dim_cancellation_reasons` (legacy-Variante) | 7 Gründe | **lossless** |
| 18 | Dropped Reasons (legacy-Variante) | 5 Gründe | **lossless** |
| 19 | Offer Refused Reasons (legacy-Variante) | 6 Gründe | **lossless** |
| 20 | Final Outcomes (Mandat) | 8 Outcomes | **lossless** |
| 21 | `dim_roles` + Mitarbeiter-Rollen-Zuordnung | 8 Rollen | **lossless** |
| 22 | `dim_event_types` | 60+ Events | **lossless** (Namen) |
| 23 | `dim_notification_templates` | 10 Templates | lossy (nur Namen) |
| 24 | `dim_prompt_templates` | 7 Templates | lossy (nur Namen) |
| 25 | `dim_ai_write_policies` | 8 Regeln | lossy (Default-Regel) |
| 26 | `dim_pii_classification` | 21 Felder | lossy (Levels benannt) |
| 27 | `dim_quality_rule_types` | 9 Regeln | lossy (nur Namen) |
| 28 | Naming Convention | Prosa | lossy (Kern-Regel) |
| 29 | `dim_email_templates` | 32 Templates | **lossless** |
| 30 | `dim_jobbasket_rejection_types` | 12 Gründe | **lossless** |
| 31 | `dim_automation_settings` v1.2 | 15 Keys | **lossless** |

**TEIL B (v1.3-Neu):**

| § | Tabelle | Einträge | Status |
|---|---------|----------|--------|
| 51 | `dim_assessment_types` | 11 Typen | **lossless** |
| 52 | `dim_rejection_reasons_internal` | 11 Gründe | **lossless** |
| 53 | `dim_honorar_settings` | 4 Stufen | **lossless** |
| 54 | `dim_culture_dimensions` | 6 Dimensionen | **lossless** |
| 55 | `dim_sia_phases` | 6 Haupt + 12 Teil | **lossless** |
| 56 | `dim_dropped_reasons` (v1.3-korrekt) | 6 Gründe | **lossless** |
| 57 | `dim_cancellation_reasons` (v1.3) | 9 Gründe | **lossless** |
| 58 | `dim_offer_refused_reasons` | 10 Gründe | **lossless** |
| 59 | `dim_vacancy_rejection_reasons` | 8 Gründe | **lossless** |
| 60 | `dim_scraper_types` | 7 Typen | **lossless** |
| 61 | `dim_scraper_global_settings` | 14 Keys | **lossless** |
| 62 | `dim_matching_weights` (Job↔Kand) | 8 Gewichte | **lossless** |
| 63 | `dim_matching_weights_project` | 6 Gewichte | **lossless** |
| 64 | `dim_reminder_templates` | 10 Templates | **lossless** |
| 65 | `dim_time_packages` | 3 Pakete | **lossless** |
| 66 | `dim_automation_settings` v1.3-Erweiterungen | 12 Keys | **lossless** |
| 67a | `dim_eq_dimensions` | 5 Dimensionen | **lossless** |
| 67b | `dim_motivator_dimensions` | 6 Kategorien × 2 Pole | **lossless** |
| 67c | `dim_assess_competencies` | 26 Kompetenzen | **lossless** |
| 67d | `dim_assess_standard_profiles` | 11 Profile | **lossless** |

**TEIL C (v1.3.4-Neu, 2026-04-17):**

| § | Tabelle | Einträge | Status |
|---|---------|----------|--------|
| 56 | `dim_document_templates` — Dok-Generator-Templates | 38 aktiv + 1 ausstehend in 7 Kategorien | **lossless** |

---

## Enums (lossless)

### §8 Sparten (`dim_sparte`)

| Code | Name | Beschreibung |
|------|------|--------------|
| ARC | Architecture | Architektur, Innenarchitektur und Design |
| GT | Building Technology | Gebäudetechnik, Netzthematiken, Energiesektor |
| ING | Civil Engineering | Ingenieurwesen, Umweltingenieure, Bauphysiker, Geotechnik |
| PUR | Procurement | Einkauf, Supply Chain, Beschaffung |
| REM | Real Estate Management | Immobilienmanagement, Immobilienentwicklung, Asset Mgmt |

### §9 Mitarbeiter (`dim_mitarbeiter`, 10 aktiv)

| Kürzel | Name | Primäre Rolle | Weitere Rollen | Team |
|--------|------|---------------|----------------|------|
| HB | Hanna van den Bosch | Researcher | — | Research |
| JV | Joaquin Vega | Candidate_Manager | — | Sales |
| LR | Luca Rochat Ramunno | Researcher | — | Research |
| NS | Nenad Stoparanovic | Admin | — | Recruiting |
| NP | Nina Petrusic | Candidate_Manager | — | Recruiting |
| PW | Peter Wiederkehr | Admin | — | Recruiting |
| ST | Sabrina Tanner | Backoffice | — | Backoffice |
| SN | Severina Nolan | Backoffice | Assessment_Manager | Backoffice |
| SP | Stefano Papes | Head_of | — | Backoffice |
| YB | Yavor Bojkov | Head_of | — | Sales |

Hinweis: 2-Buchstaben-Kürzel werden in UI verwendet (z.B. PW, JV, LR), nicht Vollnamen. UUIDs siehe Original §9.

### §10 Owner Teams

- `team_arc_rem` — Team ARC & REM (Architecture · Real Estate Management)
- `team_ing_bt` — Team ING & BT (Civil Engineering · Building Technology)
- PUR wird je nach Mandat einem der zwei Teams zugeordnet (kein eigenes Team).

### §10a Kontakt-Org-Funktion (`dim_org_functions`, 5 Codes, single-select)

| Code | Label | Kurz |
|------|-------|------|
| `vr_board` | VR / Board | V |
| `executive` | Executive | E |
| `hr` | HR | H |
| `einkauf` | Einkauf | K |
| `assistenz` | Assistenz | A |

### §10b Dossier-Send-Preference (`dim_dossier_preferences`)

`email_hr`, `email_decision_maker`, `email_assistenz`, `portal_upload`, `physisch_post`, `physisch_persoenlich`, `nicht_definiert`.

### §10c Vorstellungs-Typ (`dim_presentation_types`)

`email_dossier`, `verbal_meeting`, `upload_portal`. Regel: Reine Telefon/Chat-Erwähnung ohne Dossier-Transfer löst **keine** Schutzfrist aus.

### §11 Kandidaten-Stages (8, in Reihenfolge)

1. Check (Default bei `candidate.created`)
2. Refresh (Ghosting/NIC/Dropped; nach 1 J in Datenschutz)
3. Premarket (Briefing/Rebriefing-History)
4. Active Sourcing (Briefing + Original CV + Diplom + Arbeitszeugnis)
5. Market Now (Aktiver Prozess)
6. Inactive (Alter > 60 oder Cold > 6 Mt)
7. Blind (nur manuell)
8. Datenschutz (POST /candidates/:id/anonymize; nach 1 J auto-Refresh)

**Temperatur:** Hot · Warm · Cold (Dringlichkeit aus ARK-Sicht).

**Wechselmotivation (8 Stufen):**
- Arbeitslos
- Will/muss wechseln
- Will/muss wahrscheinlich wechseln
- Wechselt bei gutem Angebot
- Wechselmotivation spekulativ
- Wechselt gerade intern & will abwarten
- Will absolut nicht wechseln
- Will nicht mit uns zusammenarbeiten

### §12 Mandat-Research-Stages (`fact_mandate_research.contact_status`, 13)

**Vorwärts-Progression (auto/gesperrt markiert):**

| Order | Stage | DB-Wert | Auto | Gesperrt |
|-------|-------|---------|------|----------|
| 1 | Research | `research` | - | - |
| 2 | Nicht erreicht | `nicht_erreichbar` | - | - |
| 3 | Nicht mehr erreichbar | `nicht_mehr_erreichbar` | - | - |
| 4 | Nicht interessiert | `nicht_interessiert` | - | - |
| 5 | Dropped | `dropped` | - | - |
| 6 | CV Expected | `cv_expected` | - | - |
| 7 | CV IN | `cv_in` | ✓ | ✓ |
| 8 | Briefing | `briefing` | ✓ | ✓ |
| 9 | GO mündlich | `go_muendlich` | ✓ | ✓ |
| 10 | GO schriftlich | `go_schriftlich` | ✓ | ✓ |

**GO-Rejections (Exit):** `rejected_oral_go`, `rejected_written_go`, `ghosted` (Timeout z.B. 14 d).

**GO-Rejection-Reasons** (referenziert `dim_rejection_reasons_candidate`):
Compensation · Role not attractive · Company not attractive · Location · Timing · Counter Offer · Personal reasons · Stay with current employer · Unknown.

Nach GO schriftlich → Jobbasket-Flow (Prelead → Mündl. GO → Schriftl. GO → Assigned → To Send) → Prozess-Pipeline ab CV Sent.

### §13 Prozess-Stages (`dim_process_stages`, 19 mit Win%)

**Pipeline-Stages (is_pipeline_stage=true, gültig für `current_process_stage`):**

| Order | Stage | Kategorie | Win% |
|-------|-------|-----------|------|
| 1 | Expose | Pipeline | 5% |
| 2 | CV Sent | Pipeline | 10% |
| 3 | TI | Pipeline | 20% |
| 4 | 1st | Pipeline | 35% |
| 5 | 2nd | Pipeline | 55% |
| 6 | 3rd | Pipeline | 70% |
| 7 | Assessment | Pipeline | 70% |
| 8 | Offer | Pipeline | 80% |
| 9 | Placement | Success | 100% |

**Analytics-Labels (is_pipeline_stage=false, vom Backend berechnet):**
On hold unseen · On hold interview · Rejected unseen · Rejected TI · Rejected 1st · Rejected 2nd · Rejected 3rd · Offer refused · Cancellation · Dropped.

### §13b Prozess-Status (`dim_process_status`, 8)

| Status | Kategorie |
|--------|-----------|
| Open | Active |
| On Hold | Paused |
| Rejected | Closed (rejected_by + reason Pflicht) |
| Placed | Success |
| Cancelled | Closed (Rückzieher nach Placement — 100% Rückvergütung) |
| Dropped | Closed (Prozess kam nicht zustande) |
| Stale | Degraded (> X d inaktiv, Default 14) |
| Closed | Closed (Garantiefrist abgelaufen) |

### §14 Activity-Types (`dim_activity_types`, 69 Einträge in 11 Kategorien) — vollständig

**Scope:** Alle Activity-Types sind Arkadium-Aktivitäten. Interview-Durchführungen (TI/1st/2nd/3rd/Assessment) sind **keine** Activity-Types — Stage-Daten in `fact_process_interviews.actual_date`.

**Kanal-Mapping:** Call → Phone, Email → Email, Meeting → In-Person. `is_auto=true` = System-Einträge. `entity_relevance`: `candidate` / `account` / `both`.

#### Kontaktberührung (6)
| # | Activity Type | Kanal | entity |
|---|---|---|---|
| 1 | Kontaktberührung - NE | Phone | candidate |
| 2 | Kontaktberührung - NE - Direkt Combox | Phone | candidate |
| 3 | Kontaktberührung - NE - Combox Nachricht | Phone | candidate |
| 4 | Kontaktberührung - NE - Notiz | Phone | candidate |
| 5 | Kontaktberührung - NE - Briefing nicht wahrgenommen | Phone | candidate |
| 6 | Kontaktberührung - Nicht mehr erreichbar | Phone | candidate |

#### Erreicht (15)
| # | Activity Type | Kanal | entity |
|---|---|---|---|
| 7 | Erreicht - NIC vor Rollenspiel | Phone | candidate |
| 8 | Erreicht - NIC nach Rollenspiel | Phone | candidate |
| 9 | Erreicht - NIC inneres Ich | Phone | candidate |
| 10 | Erreicht - NIC Pitch | Phone | candidate |
| 11 | Erreicht - CV expected | Phone | candidate |
| 12 | Erreicht - Meeting vor Ort | In-Person | candidate |
| 13 | Erreicht - Dropped | Phone | candidate |
| 14 | Erreicht - Appointment | Phone | candidate |
| 15 | Erreicht - Update Call | Phone | both |
| 16 | Erreicht - Doc Chase | Phone | candidate |
| 17 | Erreicht - CV Chase | Phone | candidate |
| 18 | Erreicht - GO Chase | Phone | candidate |
| 19 | Erreicht - GO Termin aus Rebriefing oder Refresh | Phone | candidate |
| 20 | Erreicht - GO Termin aus oder im Briefing | Phone | candidate |
| 21 | Erreicht - Absage im GO Termin | Phone | candidate |

#### Emailverkehr (11)
| # | Activity Type | entity |
|---|---|---|
| 22 | Emailverkehr - Allgemeine Kommunikation | both |
| 23 | Emailverkehr - CV Chase | candidate |
| 24 | Emailverkehr - Absage Briefing | candidate |
| 25 | Emailverkehr - Absage Bewerbung | account |
| 26 | Emailverkehr - Absage vor GO Termin | candidate |
| 27 | Emailverkehr - Mündliche GOs versendet | account |
| 28 | Emailverkehr - Absage nach GO Termin | account |
| 29 | Emailverkehr - Schriftliche GOs | account |
| 30 | Emailverkehr - Eingangsbestätigung Bewerbung | candidate |
| 31 | Emailverkehr - Mandatskommunikation | account |
| 32 | Emailverkehr - AGB Verhandlungen | account |

#### Messaging (3)
| # | Activity Type | Kanal |
|---|---|---|
| 33 | Messaging - LinkedIn | LinkedIn |
| 34 | Messaging - Xing | Xing |
| 35 | Messaging - SMS / Whatsapp | Whatsapp |

#### Interviewprozess (9)
| # | Activity Type | entity |
|---|---|---|
| 36 | Erreicht - Coaching 1st Interview | candidate |
| 37 | Erreicht - Debriefing 1st Interview | both (2 History-Einträge) |
| 38 | Erreicht - Coaching 2nd Interview | candidate |
| 39 | Erreicht - Debriefing 2nd Interview | both |
| 40 | Erreicht - Coaching 3rd Interview | candidate |
| 41 | Erreicht - Debriefing 3rd Interview | both |
| 42 | Erreicht - Referenzauskunft | candidate |
| 65 | Erreicht - Coaching TI | candidate |
| 66 | Erreicht - Debriefing TI | both |

#### Placementprozess (6)
| # | Activity Type | entity |
|---|---|---|
| 43 | Erreicht - Offerbesprechung | both |
| 44 | Erreicht - Placement Call | candidate |
| 45 | Erreicht - Onboarding Call | candidate |
| 67 | Erreicht - 1-Mt-Check | candidate |
| 68 | Erreicht - 2-Mt-Check | candidate |
| 69 | Erreicht - 3-Mt-Check (= Garantiefrist-Ende AGB §5) | candidate |

#### Refresh Kandidatenpflege (3)
46 Erreicht - Refresh in Probezeit · 47 Erreicht - Refresh Not Interested Currently · 48 Erreicht - Refresh offen für GOs (alle candidate, Phone).

#### Mandatsakquise (4, alle account, Phone)
49 Erreicht - Mandatshunt · 50 Erreicht - Mandatsbesprechung · 51 Erreicht - Mandatsverhandlung · 52 Erreicht - AGB Verhandlungen.

#### Erfolgsbasis (2, alle account)
53 Erfolgsbasis - AGB Verhandlungen (Phone) · 54 Erfolgsbasis - AGB bestätigt (Email, eingehend).

#### Assessment (4)
55 Assessment - Link versendet (Email, candidate) · 56 Assessment - Ergebnisse erfasst (System, ✓auto, candidate) · 57 Erreicht - Assessment Akquise (Phone, account) · 58 Erreicht - Assessmentbesprechung (Phone, account).

#### System / Meta (6)
| # | Activity Type | is_auto | entity |
|---|---|---|---|
| 59 | Keine Preleads | - | candidate |
| 60 | Inactive | ✓ | candidate |
| 61 | GO Ghosting | ✓ | candidate |
| 62 | Briefing | ✓ | candidate |
| 63 | Rebriefing | ✓ | candidate |
| 64 | Schutzfrist - Status-Änderung | ✓ | both |

**Auto-logged Summary:** 6 is_auto=true (Inactive, GO Ghosting, Briefing, Rebriefing, Assessment Ergebnisse, Schutzfrist Status-Änderung). Übrige 60 manuell.

### §15 Absagegründe Kandidat (`dim_rejection_reasons_candidate`, 13)

Compensation · Role not attractive · Company not attractive · Location · Timing · Counter Offer · Personal Reasons · Stay with current employer · Offer refused · Process too slow · Lost interest · No feedback · Unknown. Kategorien: Candidate Decision / Process Issue / Unknown.

### §16 Absagegründe Kunde (`dim_rejection_reasons_client`, 16)

Skills mismatch · Industry mismatch · Seniority mismatch · Leadership mismatch · Cultural fit · Communication · Motivation · Salary too high · Availability too late · Location · Better candidates available · Job on hold · Role changed · Internal candidate · No longer hiring · Unknown. Kategorien: Profile Fit / Personal Fit / Motivation / Compensation / Availability / Market Comparison / Process Issue / Unknown.

### §17 Cancellation Reasons (v1.2-Variante, 7) — siehe auch §57 (v1.3)

Candidate resigned · Company termination · Role mismatch · Cultural mismatch · Relocation · Counter offer accepted · Unknown. Cancellation = Rückzieher Kandidat NACH Placement.

### §18 Dropped Reasons (v1.2, 5) — siehe auch §56 (v1.3)

Position already filled · Client not working with agency · Internal hire · Budget stopped · Unknown.

### §19 Offer Refused Reasons (v1.2, 6) — siehe auch §58 (v1.3)

Compensation · Counter Offer · Role not attractive · Location · Stay with current employer · Unknown.

### §20 Final Outcomes Mandat (8)

Placement (Success) · Client Rejected (Client Rejection) · Candidate Rejected (Candidate Rejection) · Offer Refused (Candidate Rejection) · Dropped (Process Lost) · Cancellation (Post Placement) · On Hold (Process Paused) · Open (Process Active).

### §21 Rollen (`dim_roles`, 8)

| role_key | role_name | Kategorie |
|----------|-----------|-----------|
| Admin | Administrator | system |
| Candidate_Manager | Candidate Manager | operations |
| Account_Manager | Account Manager | operations |
| Researcher | Research Analyst | operations |
| Head_of | Head of Division | management |
| Backoffice | Backoffice | support |
| Assessment_Manager | Assessment Manager | operations |
| ReadOnly | Nur Lesen | system |

Multi-Rollen möglich über `bridge_mitarbeiter_roles` (z.B. Severina = Backoffice + Assessment_Manager).

### §22 Event Types (`dim_event_types`, 60+)

**Candidate:** `candidate.created/updated/stage_changed/deleted/restored/merged/anonymized/datenschutz_requested/linkedin_imported/temperature_changed/wechselmotivation_changed`.
**Process:** `process.created/stage_changed/placed/closed/reopened/on_hold/rejected/stale_detected`.
**Job:** `job.created/stage_changed/filled/cancelled/vacancy_detected/published/filled_externally`.
**Mandate:** `mandate.created/stage_changed/completed/cancelled/activated/research_stage_changed`.
**Jobbasket:** `jobbasket.candidate_added/go_oral/go_written`.
**Call:** `call.received/transcript_ready/missed`.
**Email:** `email.received/sent/bounced`.
**Document:** `document.uploaded/cv_parsed/ocr_done/embedded/reparsed`.
**System:** `history.created/ai_summary_ready/data_quality_issue/circuit_breaker_tripped/dead_letter_alert/retention_action`.
**Scrape:** `scrape.change_detected/new_job_detected/person_left/new_person/role_changed`.
**Match:** `match.score_updated/suggestion_ready`.
**Account:** `account.contact_left`.
**Reminder:** `reminder.overdue`.
**Assessment:** `assessment.completed/invite_sent/expired`.

v1.2-Änderungen: `skill.market_value_updated` ENTFERNT (Skills deprecated).

### §29 Email-Templates (`dim_email_templates`, 32)

| # | Template-Key | Kategorie | Automation | Linked Activity |
|---|---|---|---|---|
| 1 | sourcing_erstansprache | Sourcing | — | Emailverkehr - Allg. Komm. |
| 2 | sourcing_followup | Sourcing | — | Emailverkehr - Allg. Komm. |
| 3 | sourcing_linkedin_inmail | Sourcing | — | Messaging - LinkedIn |
| 4 | cv_chase | CV & Dokumente | — | Emailverkehr - CV Chase |
| 5 | doc_chase | CV & Dokumente | — | Emailverkehr - Allg. Komm. |
| 6 | cv_danke | CV & Dokumente | — | Emailverkehr - Eingangsbest. Bewerbung |
| 7 | briefing_einladung | Briefing | — | Emailverkehr - Allg. Komm. |
| 8 | briefing_erinnerung | Briefing | — | Emailverkehr - Allg. Komm. |
| 9 | briefing_absage_kandidat | Briefing | — | Emailverkehr - Absage Briefing |
| 10 | go_muendliche_versand | GO-Prozess | ⚡ jobbasket.is_oral_go + mandate_research → go_muendlich | Emailverkehr - Mündl. GOs versendet |
| 11 | go_absage_vor_termin | GO-Prozess | — | Emailverkehr - Absage vor GO Termin |
| 12 | go_absage_nach_termin | GO-Prozess | — | Emailverkehr - Absage nach GO Termin |
| 13 | cv_versand_kunde | Versand | ⚡ process.created + jobbasket → cv_sent | Emailverkehr - Allg. Komm. |
| 14 | expose_versand_kunde | Versand | ⚡ process.created + jobbasket → expose_sent | Emailverkehr - Allg. Komm. |
| 15 | bewerbung_absage_kunde | Versand | — | Emailverkehr - Absage Bewerbung |
| 16 | interview_einladung | Interview | — | Emailverkehr - Allg. Komm. |
| 17 | interview_bestaetigung | Interview | — | Emailverkehr - Allg. Komm. |
| 18 | interview_vorbereitung | Interview | — | Emailverkehr - Allg. Komm. |
| 19 | interview_absage_kandidat | Interview | — | Emailverkehr - Absage Bewerbung |
| 20 | offer_begleitung | Placement | — | Emailverkehr - Allg. Komm. |
| 21 | placement_gratulation | Placement | — | Emailverkehr - Allg. Komm. |
| 22 | onboarding_info | Placement | — | Emailverkehr - Allg. Komm. |
| 23 | probezeit_checkin | Placement | — | Emailverkehr - Allg. Komm. |
| 24 | mandat_statusreport | Mandate | — | Emailverkehr - Mandatskomm. |
| 25 | mandat_kickoff | Mandate | — | Emailverkehr - Mandatskomm. |
| 26 | agb_versand | Mandate | — | Emailverkehr - AGB Verhandlungen |
| 27 | mandatshunt_erstansprache | Mandate | — | Emailverkehr - Allg. Komm. |
| 28 | assessment_link | Assessment | ⚡ Invite-Status → sent | Assessment - Link versendet |
| 29 | assessment_erinnerung | Assessment | — | Emailverkehr - Allg. Komm. |
| 30 | assessment_ergebnis_kunde | Assessment | — | Emailverkehr - Mandatskomm. |
| 31 | allgemein_blanko | Allgemein | — | AI-Vorschlag |
| 32 | refresh_kontakt | Allgemein | — | Emailverkehr - Allg. Komm. |

**Platzhalter:** `{{kandidat_vorname}}`, `{{kandidat_nachname}}`, `{{kandidat_name}}`, `{{account_name}}`, `{{job_titel}}`, `{{mandat_name}}`, `{{sparte}}`, `{{datum}}`, `{{start_datum}}`, `{{consultant_vorname}}`, `{{consultant_nachname}}`, `{{consultant_telefon}}`, `{{consultant_email}}`, `{{signatur}}`, `{{fehlende_dokumente}}`, `{{preleads_liste}}`.

### §30 Jobbasket-Ablehnungsgründe (`dim_jobbasket_rejection_types`, 12)

**candidate-Seite:** Nicht interessiert · Bereits dort beworben · Schlechte Erfahrung · Zu weit weg · Gehalt zu tief · Kein Interesse an Branche.
**cm-Seite:** Nicht passend (Profil) · Kein offenes Mandat · Bereits genug Kandidaten.
**am-Seite:** Account aktuell gesperrt · Hiring Freeze · Andere Priorität.

### §31 Automation-Settings v1.2 (`dim_automation_settings`, 15 Keys)

| Key | Default | Typ |
|---|---|---|
| ghosting_frist_tage | 14 | int |
| stale_prozess_tage | 14 | int |
| inactive_alter | 60 | int |
| datenschutz_reset_tage | 365 | int |
| briefing_reminder_tage | 7 | int |
| klassifizierung_eskalation_1h | 24 | int |
| klassifizierung_eskalation_2h | 48 | int |
| cold_inactive_monate | 6 | int |
| onboarding_reminder_tage | 7 | int |
| post_placement_checkin_1 | 30 | int |
| post_placement_checkin_2 | 60 | int |
| post_placement_checkin_3 | 90 | int |
| data_retention_warnung_tage | 30 | int |
| klassifizierung_ziel_pct | 95 | int |
| interview_datum_reminder_tage | 2 | int |

### §51 Assessment-Typen (`dim_assessment_types`, 11)

| ID | Type-Key | Display-Name | Partner | Dauer (min) |
|----|----------|-------------|---------|-------------|
| at_001 | mdi | Management-Dimensions-Inventory (MDI) | SCHEELEN | 60 |
| at_002 | relief | Relief | SCHEELEN | 45 |
| at_003 | assess_5_0 | ASSESS 5.0 | ASSESS 5.0 | 75 |
| at_004 | disc | DISC-Test | SCHEELEN | 30 |
| at_005 | eq | EQ Test | SCHEELEN | 45 |
| at_006 | scheelen_6hm | Scheelen 6 Human Needs | SCHEELEN | 30 |
| at_007 | driving_forces | Driving Forces | TTI | 40 |
| at_008 | human_needs | Human Needs / BIP | SCHEELEN | 60 |
| at_009 | ikigai | Ikigai | intern | 60 |
| at_010 | ai_analyse | AI-Analyse | intern | — |
| at_011 | teamrad_session | Teamrad-Session | intern | 90 |

### §52 Prozess-interne Ablehnungsgründe (`dim_rejection_reasons_internal`, 11)

| ID | Grund |
|----|-------|
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

### §53 Honorar-Staffel (`dim_honorar_settings`, 4 Stufen)

| ID | Gehaltsbereich | Prozentsatz |
|----|----------------|-------------|
| hs_01 | < CHF 90'000 | 21% |
| hs_02 | CHF 90'000 – 109'999 | 23% |
| hs_03 | CHF 110'000 – 129'999 | 25% |
| hs_04 | ≥ CHF 130'000 | 27% |

Ab 2027: 23/25/27/29% (via `honorar_staffel_valid_from` Tenant-Setting).

### §54 Kultur-Analyse-Dimensionen (`dim_culture_dimensions`, 6)

| ID | Dimension | Low-End | High-End |
|----|-----------|---------|----------|
| cd_01 | Leistungsorientierung | entspannt, prozessorientiert | performanceorientiert, ambitioniert |
| cd_02 | Innovationskultur | konservativ, bewährt | disruptiv, experimentell |
| cd_03 | Autonomiespielraum | direktiv, zentralisiert | eigenverantwortlich, dezentral |
| cd_04 | Feedbackkultur | hierarchisch, sparsam | offen, 360° |
| cd_05 | Hierarchieflachheit | vertikal, stark strukturiert | flach, kollegial |
| cd_06 | Transformationsreife | stabilitätsorientiert | veränderungsfreudig |

Scores 0–100 pro Dimension, Gesamt-Kulturfit-Score als gewichtete Summe.

### §55 SIA-Phasen (`dim_sia_phases`, 6 Haupt + 12 Teil)

| ID | SIA-Nr. | Name | Parent | Level |
|----|---------|------|--------|-------|
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

### §56 Prozess-Drop-Gründe v1.3 (`dim_dropped_reasons`, 6)

| ID | Grund |
|----|-------|
| dr_01 | Kunde hat Prozess nicht gestartet (keine Rückmeldung nach CV-Versand) |
| dr_02 | Kandidat hat sich nicht zurückgemeldet (Kontakt abgebrochen) |
| dr_03 | Technischer Fehler beim Versand (Email-Bounce, etc.) |
| dr_04 | Kunde hat CV zurückgewiesen ohne Prozess-Eröffnung |
| dr_05 | Mandat wurde vor Prozess-Start gekündigt |
| dr_06 | Sonstiges |

### §57 Cancellation-Gründe v1.3 (`dim_cancellation_reasons`, 9)

| ID | Grund | Seite |
|----|-------|-------|
| cr_01 | Kandidat nimmt Gegenangebot des aktuellen Arbeitgebers an | Kandidat |
| cr_02 | Kandidat hat alternatives Angebot angenommen | Kandidat |
| cr_03 | Kandidat persönliche Gründe (familiär, gesundheitlich) | Kandidat |
| cr_04 | Kunde zieht Position zurück (interne Restrukturierung) | Kunde |
| cr_05 | Kunde zieht Position zurück (Budget-Freeze) | Kunde |
| cr_06 | Relocation gescheitert | Kandidat |
| cr_07 | Visa / Arbeitserlaubnis-Probleme | Kandidat |
| cr_08 | Kulturfit-Probleme nach Vertragsprüfung | beidseitig |
| cr_09 | Sonstiges | — |

100% Rückvergütung bei Status = Cancelled.

### §58 Angebots-Ablehnungs-Gründe (`dim_offer_refused_reasons`, 10)

| ID | Grund |
|----|-------|
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

### §59 Vakanz-Rejection-Gründe (`dim_vacancy_rejection_reasons`, 8)

| ID | Grund |
|----|-------|
| vrr_01 | Stelle ist bereits intern besetzt / nicht mehr aktiv |
| vrr_02 | Nicht im Arkadium-Marktsegment (falsche Sparte) |
| vrr_03 | Account ist Blacklisted / No-Hunt |
| vrr_04 | Duplicate-Detection fehlgeschlagen |
| vrr_05 | Scraper-Extraktion fehlerhaft |
| vrr_06 | Stelle ist nur für interne Bewerber |
| vrr_07 | Temp- / Aushilfs-Position |
| vrr_08 | Sonstiges |

### §60 Scraper-Typen (`dim_scraper_types`, 7)

| ID | Type-Key | Display-Name | Impl. | Intervall (h) | Rate/h | Phase |
|----|----------|-------------|-------|--------------|--------|-------|
| st_01 | team_page | Team-Page (Kontakte) | Spezialisiert | 24 | 10 | 1 |
| st_02 | career_page | Career-Page (Vakanzen) | Spezialisiert | 12 | 15 | 1 |
| st_03 | impressum_agb | Impressum / AGB | Generisch + AI | 168 | 5 | 1 |
| st_04 | linkedin_job_change | LinkedIn Job-Wechsel | Spezialisiert | 24 | API-Limit | 2 |
| st_05 | external_jobboards | Externe Jobboards (jobs.ch, alpha.ch) | Spezialisiert | 6 | 30 | 1 |
| st_06 | pr_reports | Geschäftsberichte / Presse | Generisch + AI | 2160 | 2 | 1 |
| st_07 | handelsregister | Handelsregister (Zefix API) | Spezialisiert | 720 | 50/d | 1 |

### §61 Scraper-Global-Settings (14 Keys)

`auto_accept_confidence_threshold` (NULL=manuell) · `error_retry_max` (3) · `n_strike_disable_threshold` (5) · `hot_account_factor` (0.5) · `warm_account_factor` (1.0) · `cold_account_factor` (2.0) · `class_a_factor` (0.75) · `class_c_factor` (1.25) · `concurrent_run_limit` (10) · `rate_limit_alert_threshold` (0.5) · `bulk_parallelism_default` (5) · `low_confidence_threshold` (0.6) · `group_uid_match_high_threshold` (0.85) · `group_uid_match_medium_threshold` (0.6).

### §62 Matching-Gewichte Job-Kandidat (`dim_matching_weights`, Σ=1.0)

w_sparte 0.15 · w_function 0.20 · w_salary 0.15 · w_location 0.10 · w_skills 0.20 · w_availability 0.10 · w_experience 0.10 · default_threshold 0.60.

### §63 Matching-Gewichte Projekt-Kandidat (`dim_matching_weights_project`)

w_cluster 0.25 · w_bkp 0.25 · w_sia 0.15 · w_volume 0.10 · w_location 0.10 · w_recency 0.15.

### §64 Reminder-Vorlagen (`dim_reminder_templates`, 10)

| ID | Key | Trigger | Empfänger |
|----|-----|---------|-----------|
| rt_01 | onboarding_call | start_date − 7d | CM |
| rt_02 | placement_1m | placed_at + 1 Mt | CM |
| rt_03 | placement_2m | placed_at + 2 Mt | CM |
| rt_04 | placement_3m | placed_at + 3 Mt | CM + AM |
| rt_05 | guarantee_end | placed_at + garantie_months | AM + CM |
| rt_06 | interview_coaching | scheduled_at − 2d | CM |
| rt_07 | interview_debriefing | scheduled_at (Abend) | CM |
| rt_08 | interview_date_missing | stage_changed_at + 2d | CM |
| rt_09 | briefing_missing | created_at + 7d | CM |
| rt_10 | info_request_auto_extend | info_requested_at + daily | AM |

Tokens: `{candidate_name}`, `{process_id}`, `{days}`, `{account_name}`, `{mandate_name}`.

### §65 Time-Mandat-Pakete (`dim_time_packages`, 3)

| ID | Paket | Slots | Preis/Slot/Woche (CHF) | Listenpreis (CHF) |
|----|-------|-------|------------------------|-------------------|
| tp_01 | Entry | 2 | 1'950 | 2'250 |
| tp_02 | Medium | 3 | 1'650 | 1'950 |
| tp_03 | Professional | 4 | 1'250 | 1'650 |

Min. 2 Slots, keine Mindestlaufzeit, 3 Wochen schriftliche Kündigung.

### §66 Automation-Settings v1.3-Erweiterungen (12 Keys)

**Prozess-Stale-Detection (JSONB):**
`process_stale_thresholds` = `{"expose":14,"cv_sent":14,"ti":7,"interview_1":14,"interview_2":14,"interview_3":14,"assessment":21,"angebot":10}` (Tage pro Stage bis Stale).

**Temperature:** `candidate_temperature_hot_threshold` (5) · `candidate_temperature_warm_threshold` (1) · `account_temperature_hot_threshold` (5) · `account_temperature_warm_threshold` (1).

**Schutzfrist:** `protection_window_base_months` (12) · `protection_window_extend_months` (4) · `protection_window_info_request_wait_days` (10).

**Assessment-Billing:** `assessment_billing_overdue_check_hour` ("02:00") · `assessment_payment_terms_days` (30).

**Batch-Hours:** `process_guarantee_closer_check_hour` ("01:00") · `process_stale_detection_hour` ("03:00") · `matching_daily_batch_hour` ("04:00").

**Referral:** `referral_amount_chf` (1000) · `referral_candidate_payout_offset_days` (90).

### §67a EQ-Dimensionen (`dim_eq_dimensions`, 5) — Scheelen/Insights MDI (Goleman)

| ID | Dimension | Kategorie |
|----|-----------|-----------|
| eq_1 | Selbstwahrnehmung | Intrapersonal |
| eq_2 | Selbstregulierung | Intrapersonal |
| eq_3 | Motivation | Intrapersonal |
| eq_4 | Soziale Wahrnehmung (Empathie) | Interpersonal |
| eq_5 | Soziale Regulierung (Soziale Kompetenz) | Interpersonal |

Skala 0–100 pro Dimension + Gesamt-EQ (Mittelwert) + Intrapersonal (eq_1+2+3) + Interpersonal (eq_4+5). **Nicht EQ-i 2.0** — Scheelen/TriMetrix EQ Musterbericht.

### §67b Motivatoren-Dimensionen (`dim_motivator_dimensions`, 6 Kategorien × 2 Pole = 12 Driving Forces)

Basis: Spranger-6-Haupttypen, TTI Success Insights.

| ID | Kategorie | L-Pol | R-Pol |
|----|-----------|-------|-------|
| mot_1 | Theoretisch | Instinktiv | Intellektuell |
| mot_2 | Ökonomisch | Idealistisch | Effizienzgetrieben |
| mot_3 | Ästhetisch | Objektiv | Harmonisch |
| mot_4 | Sozial | Eigennützig | Altruistisch |
| mot_5 | Individualistisch | Kooperativ | Machtorientiert |
| mot_6 | Traditionell | Aufgeschlossen | Prinzipientreu |

Skala 0–100 pro Pol. **Gruppierung:** 4 höchste = primär ("P") · 4 mittlere = situativ ("S") · 4 niedrigste = indifferent ("I"). Primäre Motivatoren bestimmen das Handeln situationsunabhängig.

### §67c ASSESS-5.0-Kompetenzen (`dim_assess_competencies`, 26)

Skala 1–10.

1. Ergebnisorientierung
2. Qualitätsfokus
3. Problemlösung
4. Entscheidungsfindung
5. Planungs- & Organisationsfähigkeit
6. Teamarbeit
7. Kommunikationsfähigkeit
8. Konfliktmanagement
9. Kundenorientierung
10. Beziehungsmanagement & Netzwerkaufbau
11. Mitarbeiterentwicklung
12. Strategisches Denken
13. Überzeugungskraft
14. Veränderungsmanagement
15. Anpassungsfähigkeit
16. Innovationsfähigkeit
17. Lernagilität
18. Unternehmerisches Handeln
19. Digitale Befähigung
20. Führung
21. Selbstreflexion
22. Selbstmanagement
23. Resilienz
24. Integrität
25. Fachliche Entwicklung
26. Diversitätskompetenz

### §56 Dok-Generator-Templates (`dim_document_templates`, 38 aktiv + 1 ausstehend, NEU 2026-04-17)

Template-Katalog für globalen Dok-Generator `/operations/dok-generator`. **1 Template pro Dokument-Variante** (Du/Sie + Rabatt/Mandat-Typ = separate Templates, nicht Parameter — User-Entscheidung 2026-04-17).

#### Mandat-Offerten (Offerte = Vertrag, gleiches Dokument)

| ID | Template-Key | Display-Name | Kinds | Multi | Status |
|-----|--------------|-------------|-------|-------|--------|
| dt_001 | `mandat_offerte_target` | Mandat-Offerte Target | mandate | — | aktiv |
| dt_002 | `mandat_offerte_taskforce` | Mandat-Offerte Taskforce | mandate | — | aktiv |
| dt_003 | `mandat_offerte_time` | Mandat-Offerte Time | mandate | — | **is_active=false (ausstehend)** |
| dt_004 | `auftragserteilung_optionale_stage` | Auftragserteilung Optionale Stage | mandate | — | aktiv |

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

#### Kategorien (7, für Sidebar-Filter)

`mandat_offerte` (4) · `mandat_rechnung` (10) · `best_effort` (8) · `assessment` (3) · `rueckerstattung` (1) · `kandidat` (5) · `reporting` (7).

#### Entity-Kinds (9, für Entity-Picker-Filter)

`mandate` · `rechnung` · `process` · `assessment_order` · `assessment_run` · `candidate` · `account` · `mitarbeiter` · `tenant`.

#### Parameter

- `sprache` (de/en — en Phase 2 via LLM)
- `empfaenger_anrede` (Herr/Frau/Team/Gleichgestellt)
- `rechnung_zahlungsfrist_tage` (14/30)

**Entschieden gegen Parameter (stattdessen eigene Templates):** Du/Sie · Mit/ohne Rabatt (Best-Effort) · Mandat-Typ Target/Taskforce/Time.

**RPO-Offerte** ist NICHT Teil des Dok-Generators — separate Dienstleistung mit eigenem Prozess-Flow (User-Entscheidung 2026-04-17).

**Phase-1-Scope:** 38 aktive Templates. Weitere Assessment-Typen (DISC/6HM/Driving Forces/Human Needs/Ikigai/AI-Analyse/Teamrad) sind im Katalog aktiv, aber Mockup filtert Phase-1 auf SCHEELEN-Produkte.

**Schema:** Siehe `ARK_DATABASE_SCHEMA_v1_3.md` §14.2 neue Tabelle `dim_document_templates` + §14.3 `fact_documents` Erweiterungen.

### §67d ASSESS-Standard-Profile (`dim_assess_standard_profiles`, 11)

| ID | Profil |
|----|--------|
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

Custom-Profile editierbar pro Tenant (`is_custom=true`). Zuordnung Kompetenzen↔Profile: `bridge_profile_competencies`.

### §6 Branchen / Sektoren (`dim_sector`, 35)

**Bau- und Immobiliensektor (11):** Architekturbüro · Baumanagement · Baustoffhandel · Bauunternehmung · Gebäudetechnik-Unternehmer · Generalplaner · GU/TU · Hersteller / Produzent · Holzbau · Immobilienunternehmen · Ingenieurbüro.
**Dienstleistungen (2):** Consultingunternehmen · NGO.
**Finanzinstitutionen (7):** Anlagefond · Asset Management · Bank · Pensionskasse · Private Equity · Vermögensverwaltung · Versicherung.
**Gesundheitssektor (4):** Alterszentrum · Biotechnologie · Pharma · Spital.
**Industrie- und Konsumgüter (6):** Detailhandel · Industrieunternehmen · Maschinenindustrie · Mischkonzerne · Nahrungsmittel · Telekommunikation.
**Öffentlicher Sektor (5):** Energieversorgung · Forschungsinstitut · Institution · Staatsbetrieb · Teilstaatliches Institut.

### §7 Sprachen (`dim_languages`, 20)

| Code | Sprache | Code | Sprache |
|------|---------|------|---------|
| lang_al | Albanisch | lang_nl | Niederländisch |
| lang_ar | Arabisch | lang_pl | Polnisch |
| lang_bs | Bosnisch | lang_pt | Portugiesisch |
| lang_zh | Chinesisch | lang_ro | Rumänisch |
| lang_de | Deutsch | lang_ru | Russisch |
| lang_en | Englisch | lang_sr | Serbisch |
| lang_fr | Französisch | lang_es | Spanisch |
| lang_el | Griechisch | lang_tr | Türkisch |
| lang_it | Italienisch | lang_hu | Ungarisch |
| lang_ja | Japanisch | lang_hr | Kroatisch |

### §1 EDV / Software-Skills (`dim_edv`, 109, lossy — Kategorien)

11 Kategorien. Für vollständige Tool-Liste → Original §1.
- **AVA / Kalkulation** (17): Arriba, Baubit Pro, Conpilot, CostX, Cosuno, Delta Bau, DELTAproject, iTWO 4.0, iTWO Site, Messerli, NEVARIS Build, Olmero, ORCA AVA, RIB iTWO, Sorba, Take-Off, WinBau.
- **BIM / CAD** (18): Allplan, ArchiCAD 2D/3D, AutoCAD, AutoCAD MEP, Autodesk Forma/InfraWorks/Revit, Cadwork, Catia, Civil 3D, MicroStation, OpenRoads Designer, PLANBAR, Rhinoceros, Solid Works, Tekla Structures, VectorWorks.
- **BIM Koordination** (8): BIM360, BIMVision, Bluebeam, COBie, IFC, Navisworks, Revizto, Solibri.
- **ERP / Finanzen** (7): Abacus, Allfa, CAE, NAV Microsoft Dynamics, NOVA, PROVI, SAP.
- **Gebäudetechnik** (19): DDScad, Dialux, ECSCAD, Eismann, EPLAN, ePlan Electric, Flixo, IDA ICE, Lesosai, MagiCAD, Niagara, Optiplan-Smart, Plancal Nova, Polysun, ProPlanner, Relux, Siemens S7, Simaris, Vago.
- **GIS / Vermessung** (9): ArcGIS, ArcView, Basement, Delphin, Dlubal, HEC-RAS, QGIS, SIA-Tec-Tool, Trimble.
- **Grafik / Design** (4): Adobe Photoshop, Affinity Designer, Fresco, Illustrator.
- **Immobilien ERP** (8): AbaImmo, Argus Estate, Fairwalter, GARAIO REM, ImmoTop2, MRI Software, Rimo R5, Yardi.
- **Office / Allgemein** (4): MS Office, Power Automate, Power BI, Visio.
- **Projektmanagement** (8): Braso, Fasttrack Schedule, Merlin Project, Monday.com, MS Project, PlanRadar, Procore, SharePoint.
- **Visualisierung** (6): Cinema 4D, Enscape, Lumion, SketchUp, Twinmotion, V-Ray.

### §2 Funktionen (`dim_functions`, ~190, lossy — Kategorien + Level-Enum)

**Level-Enum:** Junior · Mid · Senior · Executive · C-Suite.

Kategorien: Analyse · Asset & Portfolio Mgmt · Bauführung · Bauherrenberatung · Bauökonomie · Beratung · Bewertung · Bewirtschaftung · Bildung · BIM & Digital · Digitalisierung · Einkauf · Facility Management · Finanzen · Führung · Führung Executive · Investment · Management · Nachhaltigkeit · Planung & Engineering · Produkt & Vertrieb · Projektentwicklung · Projektmanagement · Sicherheit · Spezialist · Support · Transaktionen · Treuhand · Vertrieb · Verwaltung.

Für exakte Funktions-Namen und Parent-Hierarchie → Original §2.

### §3 Ausbildung (`dim_education`, 503, lossy — Level-Enum)

**Level-Enum (19):** Berufsfachschule · CAS · DAS · Dipl. · Doktorat · EFZ/EBA · Eidg. Dipl. · EMBA · ETH Bachelor · ETH Master · FH Bachelor · FH Master · HF · HF NDS · MAS · MBA · Uni Bachelor · Uni Master · Vorbereitungskurs.

**Felder (Auswahl):** Architektur · Bauingenieurwesen · Bauphysik · Bauherrenberatung · Bauökonomie · Digitalisierung Bau · Energie & Umwelt · Holzbau · Immobilien · Kaufmännisch · Management · Natur & Umwelt · Projektmanagement · Recht · Sicherheit · Wirtschaft · u.v.m.

Für vollständige Liste (z.B. alle CAS/MAS-Titel) → Original §3.

### §4 Cluster (`dim_cluster`, ~97, lossy — Sparte-Gruppierung)

**Typ = Sparte-Gruppe:**
- **Architecture (CL_010 Entwicklung/Akquisition · CL_011 Planung/Projektierung · CL_012 Realisierung · CL_013 Bauökonomie · CL_014 Bauherrenberatung · CL_015 Spezialteam)** — mit Subclustern SC_048–SC_066.
- **Building Technology (CL_001 HLKS · CL_002 Elektro+GA · CL_003 SIBE · CL_004 Energie)** — mit Subclustern SC_001–SC_015 (Heizung, Lüftung, Klima, Kälte, Sanitär, Brand-/Blitzschutz, Fernwärme, Elektro, Gebäudeautomation, MSRL, Risiko/Sicherheit, Energie, Netzbau, PV, Kraftwerke, E-Mobility).
- **Civil Engineering (CL_005 Infrastruktur · CL_006 Kunstbau/Hochbau · CL_007 Wasserbau · CL_008 Vermessung · CL_009 Grundbau/Geotechnik/Umwelt)** — mit Subclustern SC_016–SC_047.
- **Real Estate Management (CL_016 Bewirtschaftung/Asset/Portfolio · CL_017 Vermarktung/Schätzung · CL_018 Bautreuhand · CL_019 Facility Management)** — mit Subclustern SC_067–SC_078.

Für vollständige Cluster- und Subcluster-Liste → Original §4.

### §5 Focus/Spezialisierung (`dim_focus`, ~200, lossy — Kategorien)

**Kategorien (27):** Allgemein · Architektur · Bauführung · Bauherrenberatung · Bauleitung · Beratung · Betrieb & FM · BIM · Digitalisierung · Einkauf & Beschaffung · Energie · Energie & Umwelt · Führung · Gebäudetechnik · Immobilien · Innenausbau · Konstruktion · Kostenmanagement · Management · Nachhaltigkeit · Natur & Umwelt · Normen & Recht · Planung · Projektentwicklung · Projektmanagement · Real Estate · Recht · Sicherheit · Spezialgebiete · Tiefbau · Vermessung · Vertrieb & Marketing.

Bekannte Duplikate (Alias): foc_239 → foc_169 (Machbarkeitsstudie), foc_202 → foc_071 (Plan- und Schemaentwicklung), KNX/MSRL/SPS in mehrfachen Variationen (foc_016/214, foc_015/203, foc_017/204).

Für vollständige Liste → Original §5.

### §23 Notification-Templates (10, lossy)

`reminder_due` (in-app/High) · `reminder_overdue` (push/Urgent) · `process_stage_changed` (in-app/Medium) · `ai_suggestion_ready` (in-app/Low) · `document_parsed` (in-app/Low) · `dead_letter_alert` (push/Urgent) · `circuit_breaker_tripped` (push/Urgent) · `candidate_datenschutz` (push/Urgent) · `scrape_change` (in-app/Medium) · `placement_success` (in-app/High).

### §24 Prompt-Templates (7, lossy)

`cv_parsing_v1` (anthropic) · `call_summary_v1` (anthropic) · `candidate_classification_v1` (openai — Generalist/Spezialist) · `seniority_classification_v1` (openai) · `dossier_generation_v1` (anthropic) · `action_items_extraction_v1` (anthropic) · `red_flag_detection_v1` (anthropic).

### §25 AI Write Policies (lossy)

Default-Regel: Alle Candidate- und Process-Felder `suggest_only` mit `review_required=true`. AI-Felder in fact_history (`ai_summary`, `ai_action_items`, `ai_red_flags`) `auto_allowed`. Verboten: `candidate.is_do_not_contact`.

### §26 PII-Klassifikation (lossy)

**Level:** `direct_identifying` · `highly_sensitive` · `sensitive_business`. Alle Namen/Email/Phone/Adresse/LinkedIn/Photo auf `dim_candidates_profile` = direct_identifying+mask. Birth_date + Salary-Felder (briefing_salary_*, salary_candidate_target) = highly_sensitive+mask. Transcript/Email-Body/Fee-Amount/Client-Budget = sensitive_business+mask.

### §27 Datenqualitätsregeln (9, lossy)

`email_missing` · `phone_missing` · `no_contact_12_months` · `potential_duplicate` · `salary_missing_in_briefing` · `account_domain_missing` · `account_no_contact` · `process_stale_30_days` (auto_fixable) · `mandate_no_research`.

### §28 Naming Convention (lossy)

**Deutsch:** Schweizer Fachbegriffe (ansprache, wohnort, arbeitsort, kuendigungsfrist, briefing_kandidatenbewertung, Bauführer, Polier, Deviseur, Bauleiter, Gebäudetechnikplaner).
**Englisch:** Generische/technische Felder (candidate_stage, phone_mobile, is_do_not_contact, email_1, is_active, created_at, row_version).
**Umlaute:** in Anzeigenamen ä/ö/ü/ss (nie ß). **DB-Feldnamen: keine Umlaute** (z.B. `kuendigungsfrist`).

---

## Key Rules (Terminologie, Wording, Konventionen)

### Sprachstandard / Routing (v1.3)

- `candidate_id` (englisch), nicht `kandidat_id`.
- Routen englisch: `/candidates`, `/accounts`, `/mandates`, `/jobs`, `/processes`, `/assessments`, `/scraper`, `/company-groups`, `/projects`.
- Status-Enums **gemischt** (intentional): Mandat + Job deutsch, Prozess + Assessment englisch.
- `fact_jobs` (operativ) — kein `dim_jobs`.
- SIA: 6 Haupt + 12 Teilphasen (nicht 11).

### Terminologie Briefing vs. Stellenbriefing (CLAUDE.md §14a)

- **Briefing** = Kandidaten-Seite (Arkadium ↔ Kandidat, Eignungsgespräch nach Hunt/Research, Jobbasket-Flow). System-Event #62 beim erstmaligen Speichern der Briefing-Maske.
- **Stellenbriefing** = Account-/Job-/Mandats-Seite (Kunde über Stelle).
- **Coaching** = Arkadium ↔ Kandidat VOR Interview (#36/38/40/65).
- **Debriefing** = Arkadium ↔ Kandidat UND Arkadium ↔ Kunde (separat, beidseitig) NACH Interview (#37/39/41/66 — pro Debriefing-Set 2 History-Einträge mit identischem Activity-Type).
- **Referenzauskunft** = Arkadium ↔ Referenzperson im Kunden-Auftrag (#42).
- **Niemals vermischen.**

### Arkadium-Rolle (CLAUDE.md §Arkadium-Rolle-Regel)

Arkadium ist **Headhunting-Boutique, nicht Interview-Teilnehmer**. Interviews (TI / 1st / 2nd / 3rd / Assessment) laufen **direkt zwischen Kandidat und Kunde** — Arkadium nicht dabei, keine Activity-Type dafür (nur `fact_process_interviews.actual_date`). **TI** = Telefon-/Teams-Interview **Kunde ↔ Kandidat** (NICHT Arkadium-Interview).

### Activity-Linking-Regel

Alle operativen UI-Felder (Check-Ins, Debriefings, Coachings, Referenzauskünfte, Stage-Transitions) sind **Projektionen von `fact_history`-Events** (nicht Primärdaten). UI-Status aus Activity-Existenz + Status berechnet, nicht als Boolean gespeichert. Jeder Dot / jede Listen-Zeile verlinkt per `data-activity-id` auf History-Drawer.

### Schutzfrist-Regel (≠ Garantiefrist)

- **Schutzfrist** (AGB §6, 12 Mt default / 16 Mt bei Kunde-Nicht-Kooperation) = Direkteinstellungs-Schutz, startet mit **Kandidaten-Vorstellung** beim Kunden (Vermittlungsversuch), **greift nur bei NICHT-Placement** (Rejection/Stale/Closed). Bei Placement → Status `honored` → inaktiv.
- **Garantiefrist** (AGB §5) = 3 Mt post-Placement, Rückvergütung bei Early-Exit.
- Niemals Schutzfrist im Post-Placement-Kontext darstellen.

### Stammdaten-Wording-Regel (CLAUDE.md)

Vor Erstellen von UI-Texten, Mockup-Labels, Filter-Optionen, Dropdown-Werten, Chip-Beschriftungen oder Timeline-Events: **Immer gegen dieses Dokument prüfen.**

**Häufige Fehler vermeiden:**
- **Prozess-Stages:** Expose · CV Sent · TI · 1st · 2nd · 3rd · Assessment · Offer · Placement (NICHT Identified/Briefing/Interview/Angebot).
- **Mandat-Typen:** Target · Taskforce · Time (NICHT Retainer/Einzelmandat/RPO).
- **Org-Funktion:** vr_board · executive · hr · einkauf · assistenz (NICHT Board/Linie/Management).
- **EQ-Dimensionen:** Selbstwahrnehmung · Selbstregulierung · Motivation · Soziale Wahrnehmung · Soziale Regulierung (NICHT Stress-Management/Anpassungsfähigkeit = EQ-i 2.0).
- **Motivatoren:** Theoretisch · Ökonomisch · Ästhetisch · Sozial · Individualistisch · Traditionell mit je 2 Polen (kein Freitext).
- **Sparten:** ARC · GT · ING · PUR · REM (NICHT Hochbau/Tiefbau = Cluster).
- **Mitarbeiter-Darstellung:** 2-Buchstaben-Kürzel PW/JV/LR (NICHT Vollname).
- **Activity-Types:** JEDE History-/Timeline-Zeile muss aus Katalog §14 stammen (69 Einträge, 11 Kategorien). Nie Freitext-Activity erfinden.

Neue Enum-Werte nur nach PO-Freigabe ergänzbar. Freie Textfelder (Notizen, Kommentare) ausgenommen.

### Keine-DB-Technikdetails-im-UI-Regel

Niemals in User-facing-Texten DB-Tabellen-/Spalten-Namen zeigen (keine `dim_*`, `fact_*`, `bridge_*`, `_fk`, `candidate_id`, `stage`). Stattdessen sprechende Benutzer-Begriffe („Stammdaten", „Liste", „Katalog", „Auswahl"). Ausnahmen nur Spec-Dokumente / Code-Kommentare / Admin-/Debug-Views.

### Umlaute-Regel

Immer echte Umlaute ä/ö/ü/Ä/Ö/Ü/ß (UTF-8). Niemals ae/oe/ue/ss als Ersatz, auch nicht in Mockups, Specs, Wiki, Code-Kommentaren oder Embeds. DB-Feldnamen bleiben ohne Umlaute (Konvention §28).

---

## Pointer to full source

Für Details zu allen weggelassenen/gekürzten §-Sektionen:
`C:\ARK CRM\Grundlagen MD\ARK_STAMMDATEN_EXPORT_v1_3.md §X`.

**Besonders betroffen (lossy im Digest, bei Bedarf Original lesen):**
- **§1 EDV** (nur Kategorien + Tool-Namen zusammengefasst — für IDs `edv_001` bis `edv_108` → Original).
- **§2 Funktionen** (nur Kategorien + Level-Enum — für alle ~190 Funktionen inkl. `fun_*`-IDs und Parent-Hierarchie → Original).
- **§3 Ausbildung** (nur Levels — für alle 503 `EDU_*`-Einträge → Original).
- **§4 Cluster** (nur Sparte-Gruppierung + Parent-Cluster — für alle `CL_*`/`SC_*` inkl. Namen → Original).
- **§5 Focus** (nur Kategorien — für alle `foc_*`-IDs → Original).
- **§22 Event-Types** (Event-Namen als Gruppen gelistet — für vollständige Tabelle mit entity_type und is_automatable → Original).
- **§23 Notification-Templates, §24 Prompt-Templates, §25 AI Write Policies, §26 PII-Klassifikation, §27 Datenqualitätsregeln, §28 Naming Convention** (Kurzfassung — für Details z.B. vollständige PII-Feldliste, exakte rule_category → Original).

**Anhang:** Sektion „Bezug zu Detailseiten-Specs" im Original (S. 2494 ff.) mappt Stammdaten auf Verwender-Specs — bei Spec-Sync-Check konsultieren.
