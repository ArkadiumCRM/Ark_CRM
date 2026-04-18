---
title: "Dokument-Templates (ARK CV, Abstract, Exposé) — Design-Spec"
type: source
created: 2026-04-08
updated: 2026-04-16
sources: ["Ark_CV_PL_Arkadium_Arkadium.docx", "Ark_Anschreiben_Abstract_Peter_Wiederkehr.pdf", "Kandidatenexpose.pdf"]
tags: [source, templates, documents, examples, ci-cd, design]
---

# Dokument-Templates

**Dateien (raw/Ark Dokumente/):**
- `Ark_CV_PL_Arkadium_Arkadium.docx` (7 Seiten) — ARK CV Dossier Template
- `Ark_Anschreiben_Abstract_Peter_Wiederkehr.pdf` (2 Seiten) — Anschreiben + Abstract Kombi
- `Kandidatenexpose.pdf` (5 Seiten) — Anonymisiertes Exposé

## Arkadium CI/CD — Visuelle Identität

**Farbpalette:**
- Navy `#1a2540` (Primary, dark bands, Logo-Schrift, H1)
- Gold/Beige `#b99a5a` bis `#d4b680` (Accent, CTA, A.-Badge, Section-Underlines)
- Weiss `#ffffff` (Haupthintergrund)
- Light Gray `#f2f2f2` (Footer-Band)
- Text-Gray `#555` / `#666` (Body-Kontrast)

**Typografie:**
- **Logo**: "Arkadium." Serif (Libre Baskerville-artig) + Subtitel "EXECUTIVE SEARCH & CONSULTING" Sans-Serif letter-spaced
- **H1/Titel**: Serif, navy, gross
- **Section-Header**: ALL CAPS, letter-spaced (`tracking 0.2em`), gold mit kurzer goldener Unterstreichungslinie
- **Body**: Sans-Serif, 10–11pt, `line-height 1.55`

**Wiederkehrende Elemente:**
- **A.-Badge**: Gold gefüllter Kreis mit serifem "A." in Navy — als Divider/Cover-Icon
- **Navy-Band-Header**: Dunkel-Navy Hintergrund mit letter-spaced gold Titel („K A N D I D A T E N E X P O S É" / „A B S T R A C T")
- **Footer-Band**: Light-Gray Band mit Arkadium-Adresse (Arkadium AG · 8041 Zürich · kontakt@arkadium.ch · +41 44 266 88 99) + LinkedIn/Instagram/WhatsApp-Icons
- **Sparten-Liste**: ARCHITECTURE · REAL ESTATE MANAGEMENT · CIVIL ENGINEERING · BUILDING TECHNOLOGY (letter-spaced, small caps, grau)
- **Claim**: „FUTURE BUILT ON POTENTIAL" (small-caps, grau, links oben)

## 1. Anschreiben · Dossier-Vorstellung (Seite 1 der Abstract-PDF)

**Layout**: Zweispaltig
- **Links (~30 %)**: Claim „FUTURE BUILT ON POTENTIAL" → Logo „Arkadium." → Sparten-Liste (vertikal, rechtsbündig)
- **Rechts (~70 %)**: Titel „D O S S I E R V O R S T E L L U N G" (Serif, navy) mit kurzer Gold-Linie darunter → Anrede „Guten Tag" → Body-Text (3 Absätze) → „Freundliche Grüsse" → Zweispaltig: DATUM | Name + Rolle
- **Footer**: Gray-Band mit Adresse + Social-Icons

**Body-Pattern (Anschreiben):**
> Wir glauben nicht an Kandidaten «von der Stange», ebenso wenig an Headhunting nach Schema F. Als dedizierte Boutique stehen wir für passgenaue Besetzungen, die nicht nur mit Ihrem Anforderungsprofil, sondern auch mit Ihrer Kultur und Strategie harmonieren.

## 2. Abstract (Seite 2 der PDF)

**Layout:**
- **Top-Band (Navy)**: „A." Gold-Badge zentriert oben → „A B S T R A C T" Gold letter-spaced → Kandidatenname weiss letter-spaced
- **Body** (2 Spalten unter Band):
  - **Links**: Foto (gross, gerahmt) → „GOOD TO KNOW" (Wohnort, Zivilstand, Mobility, Pensum, Kündigungsfrist, Status, Eintrittsdatum, Verhandlungsbasis, Verpflichtung) → „EDV-KENNTNISSE" (mit Balken-Indikatoren)
  - **Rechts**: „WARUM [NAME]?" (Pitch) → „INTRINSISCHE MOTIVATION" → „KOMPETENZEN" (Bullet-Liste) → „REFERENZEN" (Arbeitgeber-Zitat)
- **CTA-Row** (full-width): „WER POTENZIALE ERKENNT, HANDELT RECHTZEITIG" — Gold-Underline — beschwörender Text
- **Footer**: Gray-Band wie Anschreiben

## 3. Kandidatenexposé (anonymisiert · 5 Seiten)

**Struktur:**
- **Seite 1 Cover**: Nur Logo „Arkadium." zentriert
- **Seite 2 Divider**: „A." Gold-Badge in Kreis über Navy-Half-Page, „K A N D I D A T E N E X P O S É" Gold gross letter-spaced
- **Seite 3–5 Content**: Jede Seite beginnt mit Navy-Top-Bar (~80px) mit „K A N D I D A T E N E X P O S É" gold letter-spaced, rechts Seitenzahl

**Content-Elemente (Seite 3 ff):**
- **Pull-Quote**: «DIE BESTEN KÖPFE DER KONKURRENZ GEHÖREN IN IHR TEAM.» — navy bold, Gold-Linie unten
- **„DARUM PASST DER ASPIRANT ZU IHNEN."**: Dunkler Stuhl-Bild links + Body-Text rechts, „Die aspirierende Person verfügt über …" (Sie-Form)
- **„BERUFLICHE TÄTIGKEIT"**: Section mit Gold-Unterstreichungslinie
  - Rolle (caps), Ort + Zeitraum, Bullet-Liste
  - Firmennamen redacted (stattdessen „Bern" / „Winterthur" als Stadt)
- **„REFERENZEN"**: Block-Text (Sie-Form), „Gemäss den Rückmeldungen seiner Arbeitgeber überzeugt die aspirierende Person durch …"
- **„PERSÖNLICHES" + „STATUS QUO"**: Zwei-Spaltig
  - Persönliches: Wohnort (Stadt), Nationalität, Geburtsdatum, Pensum, Kündigungsfrist, Status
  - Status Quo: Aus-/Weiterbildung
- **Gold CTA-Button**: „Das komplette Profil erhalten." auf goldenem Rechteck
- **Pull-Quote Footer**: «DAS GANZE BILD STÄRKT IHRE ENTSCHEIDUNGSFREIHEIT.»

**Anonymisierungs-Wording (wichtig für Mockup):**
- Statt Name: "die aspirierende Person" / "der Aspirant" / "sie/ihre" (er-Person abgelöst durch Sie-Form)
- Statt Firmenname: Stadt (BERN / WINTERTHUR / ZÜRICH)
- Geburtsdatum bleibt (nicht nur Alter)
- Kein Foto
- Kontaktdaten komplett raus
- Schluss-Absatz: „Es handelt sich hierbei um ein anonymisiertes Kandidatendossier. Auf ausdrücklichen Wunsch stellen wir Ihnen gerne das personalisierte Dossier des Kandidaten zu."
- AGB-Hinweis: „Bitte beachten Sie, dass im Falle der Zustellung des personalisierten Dossiers unsere Allgemeinen Geschäftsbedingungen (AGB) gelten."

## 4. ARK CV · Dossier (docx, 7 Seiten)

**Layout-Hinweise aus docx:**
- Cover-Seite mit Name + „KANDIDATENDOSSIER"
- Sektion „Überblick" (Kurzprofil)
- **PERSÖNLICHES** (Wohnort, Nationalität, Heimatort, Geburtsdatum, Zivilstand, Führerausweis)
- **ERFOLGE** (Bullet-Liste)
- **STATUS QUO**
- **SPRACHEN**
- **INTERESSEN / HOBBIES**
- **AUS- UND WEITERBILDUNG** (BACHELOR, Kurse, Seminare) — Rolle caps, Institution + Jahr
- **BERUFLICHE TÄTIGKEIT** — gleiche Pattern wie Exposé (Rolle caps, Firma + Ort, Zeitraum, Bullet-Liste)
- **METHODEN UND SOFTSKILLS** / **HARDSKILLS**
- **Projektauszug** (dedizierte Seiten) — Projekte mit Bauherr · Beschrieb · Bausumme · Kompetenz
- **Footer-Text**: „Das vorliegende Dossier wurde durch die Arkadium AG, einem unabhängigen Schweizer Executive Search & Consulting Unternehmen eingereicht …"
- **Seitenzahlen unten rechts** („3/7")
- **Header links**: LinkedIn + KONTAKT mit Arkadium-Adresse
- **Header rechts (Name)**: Nenad Stoparanovic

## Zentrale Design-Regeln für Dok-Generator

1. **Brand-Farben verbindlich**: Navy + Gold, keine Abweichung
2. **A.-Badge** bei Abstract + Exposé-Divider
3. **Navy-Top-Bar** auf allen Exposé-Content-Seiten
4. **Gold-Underline** unter jedem Section-Header (kurz, ca. 30 mm)
5. **Letter-spaced Caps** für Section-Titel (`letter-spacing: 0.2em`)
6. **Anonymisierungs-Wording** bei Exposé: „aspirierende Person", „sie", Stadt statt Firma
7. **Footer-Band** (gray) mit Arkadium-Kontaktdaten auf allen Seiten

## Verlinkte Wiki-Seiten
- [[kandidat]]
- [[dokumente]]
- [[anonymisierung-schutzfrist]]

## Verwendung im Mockup
- `mockups/candidates.html` Tab 9 Dok-Generator — WYSIWYG-Canvas pro Typ mit diesen Layouts
