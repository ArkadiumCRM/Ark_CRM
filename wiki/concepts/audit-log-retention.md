---
title: "Audit-Log Retention"
type: concept
created: 2026-04-14
updated: 2026-04-14
sources: ["fact_audit_log", "ARK_BACKEND_ARCHITECTURE_v2_5.md"]
tags: [audit, retention, compliance, archivierung]
---

# Audit-Log Retention

Policy für `fact_audit_log` + `fact_history` — Aufbewahrungs- und Archivierungsregeln.

## Kategorien

| Kategorie | Beispiele | Retention (Hot) | Archiv | Löschung |
|-----------|-----------|-----------------|--------|----------|
| **Kritisch** | Schutzfrist-Events, Mandat-Kündigung, Claim, Admin-Override, Placement (TX1), Payment | 7 Jahre Hot | — | Nie |
| **Standard** | Stage-Änderungen, Kontakt-CRUD, Kandidat-Updates | 3 Jahre Hot | Jahre 4–7 komprimiert | 7 Jahre |
| **Noise** | UI-Interaktionen (View, Filter), Login/Logout | 90 Tage Hot | 1 Jahr | 1 Jahr |

## Technik

- **Hot-Storage:** `fact_audit_log` PostgreSQL mit monatlicher Partitionierung (`PARTITION BY RANGE (created_at)`).
- **Cold-Archiv:** Partitionen > 3 Jahre → `archive.audit_log_{YYYY_MM}` (komprimiert via pg_dump + S3 Glacier).
- **Worker:** `audit-log-archiver.worker.ts` monatlich (1. des Monats, 03:00).

## Legal Hold

Bei laufenden Rechtsstreitigkeiten oder Regulatory-Requests:
- `fact_audit_log.legal_hold BOOLEAN DEFAULT FALSE`
- Während `legal_hold=TRUE`: **keine** Archivierung, **keine** Löschung, unabhängig von Retention-Policy.
- Setzen/Aufheben: Admin-only, eigener Audit-Event `legal_hold_toggled`.

## DSGVO/Recht-auf-Löschung

Bei User-Löschantrag (Kandidat/Kontakt):
- Personenbezogene Felder (Name, Email, Phone) werden in `fact_audit_log.payload` **gehasht** (SHA-256 mit Tenant-Salt), nicht gelöscht.
- `fact_history` bleibt strukturell erhalten (Business-Kontinuität), aber mit gehashten Personendaten.
- Audit-Event `personal_data_hashed` als Nachweis.

## Related

[[backend-architecture]], [[rbac-matrix]]
