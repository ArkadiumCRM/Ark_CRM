---
title: "Dokumente"
type: concept
created: 2026-04-08
updated: 2026-04-08
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_2.md", "ARK_DATABASE_SCHEMA_v1_2.md"]
tags: [concept, dokumente, upload, generator]
---

# Dokumente

Upload, Verwaltung und Generierung von Dokumenten. Tabelle: `fact_documents`.

## Dokument-Typen

| Typ | Phase |
|-----|-------|
| Original CV | 1 |
| ARK CV | 1 |
| Exposé | 1 |
| Abstract | 1 |
| Diplom | 1 |
| Arbeitszeugnis | 1 |
| Assessment-Dokument | 1 |
| Vertrag | 1 |
| Mandat-Report | 2 |
| Rechnungen | 2 |
| Assessment-Reports | 2 |
| Zeitreports | 2 |

**Max Upload:** 20 MB

## Dokumenten-Pipeline

```
Upload → MIME/Hash/Size Check → Malware Scan → OCR → CV Parsing → Embedding → AI-Vorschläge
```

## Dok-Generator (Phase 1)

WYSIWYG Editor für:
- **ARK CV** — Standardisiertes CV-Format
- **Abstract** — Kurzprofil
- **Exposé** — Ausführliches Profil für Kunden

Zieht Daten aus allen Kandidaten-Tabs. PDF-Export, versioniert.

## Mandate-Report-Generator (Phase 2)

Generiert Status-Reports für Mandate-Kunden:
- Longlist-Status (Kandidaten pro Stage)
- Anrufstatistiken (Call-Target vs. Actual)
- Pipeline-Fortschritt (Prozesse und Stages)
- Timeline (Kickoff → heute)

Manuell oder periodisch generierbar, per Email versendbar.

## Retention Classes

| Klasse | Beschreibung |
|--------|-------------|
| standard | Normale Aufbewahrung |
| sensitive | Erhöhter Schutz |
| legal_hold | Rechtliche Aufbewahrungspflicht |
| anonymized | Anonymisiert (GDPR) |

## Related

- [[kandidat]] — Tab 8 (Dokumente) + Tab 9 (Dok-Generator)
- [[ai-system]] — OCR, CV Parsing, Embedding Pipeline
- [[mandat]] — Mandate-Reports
