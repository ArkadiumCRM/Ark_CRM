---
title: "Email-System"
type: concept
created: 2026-04-08
updated: 2026-04-17
sources: ["ARK_GESAMTSYSTEM_UEBERSICHT_v1_3.md", "ARK_BACKEND_ARCHITECTURE_v2_5.md"]
tags: [concept, email, outlook, kalender, integration]
---

# Email-System

CRM als zentrales Kommunikationstool (Email + Kalender). MS Graph Integration mit **individuellen User-Tokens** pro Mitarbeiter.

## Detailmaske

`mockups/email-kalender.html` — Operations/Email & Kalender · Segment-Toggle Email ↔ Kalender · 3-Pane Email-Layout · Woche/Tag/Monat Kalender-Views · 7 Drawer (Compose/Event/Create-Kandidat/Create-Account/Template-Picker/Konten/Entity-Match).

## Funktionen

- **Email-Composer** im CRM (MS Graph Send · Quick-Reply inline + Compose-Drawer für Erweiterung)
- **Email-Inbox** (MS Graph Sync · Auto-Klassifikation Kandidat/Mandat/Account/Unbekannt)
- **38 Standard-Templates** (4 mit Automation-Trigger für Mündliche GOs · Schriftliche GOs · Prelead-Info · Schutzfrist-Hinweis)
- **Erweiterbar** durch Admins (Template-CRUD)
- **Entwürfe** im CRM speicherbar (`fact_email_drafts`)
- **Unbekannte Emails** → Fuzzy-Match-Drawer → existierend zuordnen / neu anlegen / ignorieren
- **Kalender**: bidirektionale Outlook-Sync, Tag/Woche/Monat-Views, Team-Overlay (frei/busy DSG)

## Templates

Gespeichert in `dim_email_templates`:
- `template_key` — Eindeutiger Schlüssel
- `linked_activity_type` — Verknüpfter Activity-Type
- `linked_automation_key` — Verknüpfte Automation

4 Templates mit Automation-Trigger (z.B. "Mündliche GOs" → Jobbasket-Update).

## Outlook-Integration (Architektur 2026-04-17)

- **Individuelle User-Tokens**: jeder Mitarbeiter OAuth-verbindet sein persönliches Outlook-Postfach einmalig (kein Shared-Mailbox-Zwischenschritt)
- **Onboarding**: neuer Mitarbeiter → Erst-Login → OAuth-Flow → fertig
- **Berechtigungen**: `Mail.Read` · `Mail.Send` · `Calendars.ReadWrite` · `offline_access`
- **Sync-Scope**: Nur Mails mit Kandidaten-/Account-Email-Adressen (+ manuell gelabelte Intern-Mails)
- Newsletter / Werbemails / System-Benachrichtigungen: Ignore-Liste pro User
- Idempotenz via `email_message_id`
- Kalender-Integration: Teams-Meetings aus CRM erstellen (bidirektional via `outlook-calendar-sync.worker`)

## Signatur-Management · CodeTwo

**Entscheidung 2026-04-17:** Signaturen werden **nicht** im CRM verwaltet, sondern via [CodeTwo Email Signatures for Office 365](https://www.codetwo.de) **server-seitig** auf Exchange-/M365-Ebene nach Versand angehängt.

**Architektur:**
- CodeTwo läuft als Azure-App auf Arkadium-Tenant-Level
- Admin verwaltet Templates zentral im CodeTwo-Admin-Panel
- Regel-Logik: pro Abteilung / User / Mandat / Kampagne unterschiedliche Templates
- CRM-Compose-Drawer **zeigt keine Signatur**, sendet nur Body — Signatur wird nach `/api/v1/emails/send` vom Exchange-Relay eingefügt
- Im CRM nur Info-Status im Konten-Drawer: aktives Template · Tenant-Scope · Link zum Admin-Panel

**Vorteile:**
- Zentrale Kontrolle (CI-konform · DSG-Fußzeilen · Marketing-Banner)
- Keine Compose-UX-Komplexität (User schreibt nur den Text)
- Out-of-Office / Kampagnen-Banner via CodeTwo-Regeln, nicht im CRM

## Ordner-Modell (Email-Maske)

| Ordner | Inhalt | Wie er gefüllt wird |
|--------|--------|---------------------|
| **Klassifiziert** | Emails mit Kandidaten-/Account-Match | Auto-Klassifikation via Adress-Lookup |
| **Unbekannt** | Emails ohne Match | Sync-Scope-Filter lässt durch, wartet auf Labeling |
| **Inbox (Intern / Sonstige)** | Business-relevant aber nicht Entity-gebunden | Manuell gelabelt aus Unbekannt (z.B. Intern, Dienstleister) |
| **Ignoriert** | Newsletter · System-Mails | Ignore-Liste (Domain/Absender/Betreff) |

## Ausfallsicherheit

1. Health-Check Worker prüft Token-Status alle 5 Min
2. Bei ablaufendem Token (< 24h): Auto-Refresh + Admin-Alert
3. Bei Fehlschlag: Banner "Email-Sync unterbrochen" (pro User)
4. Mitarbeiter kann temporär direkt über Outlook arbeiten
5. Nachhol-Sync wenn Token wieder gültig

## Related

- [[automationen]] — Email-Template-Trigger
- [[history-system]] — Emails als Activity-Types
- [[telefonie-3cx]] — Zweiter Kommunikationskanal
- [[backend-architektur]] — Outlook Worker + Calendar-Sync-Worker
