# ARK CRM — BKP-Codes Stammdaten mit SIA-Phasen-Verknüpfung

## Legende & Metadaten

- **Dokument:** ARK CRM — BKP-Codes Stammdaten mit SIA-Phasen-Verknüpfung
- **Stand:** 02.04.2026
- **Sheet:** Beschreibung
- **dim_sia_phases:** 6 Phasen + 12 Teilphasen nach SIA 112 Leistungsmodell
- **dim_bkp_codes:** Komplette BKP-Liste (SN 506 500) mit BC/WC-Zuordnung und Recruiting-Relevanz
- **bridge_bkp_sia_phases:** Verknüpfung: Welcher BKP-Code in welchen SIA-Teilphasen relevant ist
- **Feld:** Beschreibung
- **code:** BKP-Code oder SIA-Phase-Code, dient als Primary Key
- **parent_code:** Übergeordneter Code (Hierarchie)
- **ebene:** 1 = Hauptgruppe/Phase, 2 = Gruppe/Teilphase, 3 = Untergruppe, 4 = Gattung
- **is_blue_collar:** Relevant für gewerbliche Mitarbeiter (Monteure, Handwerker etc.)
- **is_white_collar:** Relevant für Angestellte (Ingenieure, Planer, Architekten etc.)
- **is_relevant:** Für Recruiting-Kandidatenprofile relevant (FALSE = reine Kostenposition)
- **phasenziel:** Ziel der SIA-Phase gemäss SIA 112

### SIA-Phasen Referenz (SIA 112)

- **Phase 1:** Strategische Planung — 11: Bedürfnisformulierung
- **Phase 2:** Vorstudien — 21: Projektdefinition, 22: Auswahlverfahren
- **Phase 3:** Projektierung — 31: Vorprojekt, 32: Bauprojekt, 33: Bewilligungsverfahren
- **Phase 4:** Ausschreibung — 41: Ausschreibung, Offertvergleich, Vergabeantrag
- **Phase 5:** Realisierung — 51: Ausführungsprojekt, 52: Ausführung, 53: Inbetriebnahme
- **Phase 6:** Bewirtschaftung — 61: Betrieb, 62: Erhaltung

### SIA Ordnungen

- **SIA 102:** Leistungen und Honorare Architektinnen/Architekten
- **SIA 103:** Leistungen und Honorare Bauingenieurinnen/Bauingenieure
- **SIA 105:** Leistungen und Honorare Landschaftsarchitektinnen
- **SIA 108:** Leistungen und Honorare Ingenieure Gebäudetechnik/Maschinenbau/Elektrotechnik
- **Vererbungsregel:** 3- und 4-stellige BKP-Codes erben die SIA-Phasen-Zuordnung ihres übergeordneten 2-stelligen Codes
- **Hinweis:** Bitte alle Zuordnungen validieren. Anpassungen im Sheet 'bridge_bkp_sia_phases' vornehmen.


---

## SIA-Phasen (`dim_sia_phases`)

_18 Einträge — 6 Hauptphasen + 12 Teilphasen nach SIA 112_

| code | parent_code | ebene | bezeichnung | phasenziel | is_active |
|---|---|---|---|---|---|
| 1 |  | 1 | Strategische Planung | Bedürfnis, Ziele und Rahmenbedingungen definiert, Lösungsstrategie festgelegt | TRUE |
| 11 | 1 | 2 | ↳ Bedürfnisformulierung, Lösungsstrategien | Bedürfnis, Ziele und Rahmenbedingungen definiert, Lösungsstrategie festgelegt | TRUE |
| 2 |  | 1 | Vorstudien | Vorgehen und Organisation festgelegt, Machbarkeit nachgewiesen | TRUE |
| 21 | 2 | 2 | ↳ Projektdefinition, Machbarkeitsstudie | Vorgehen und Organisation festgelegt, Projektierungsgrundlagen definiert, Machbarkeit nachgewiesen | TRUE |
| 22 | 2 | 2 | ↳ Auswahlverfahren | Projekt ausgewählt, welches den Anforderungen am besten entspricht | TRUE |
| 3 |  | 1 | Projektierung | Projekt bewilligt, Kosten und Termine verifiziert | TRUE |
| 31 | 3 | 2 | ↳ Vorprojekt | Konzeption, Funktion und Wirtschaftlichkeit definiert | TRUE |
| 32 | 3 | 2 | ↳ Bauprojekt | Projekt (Platzbedarf) und Kosten optimiert, Termine definiert | TRUE |
| 33 | 3 | 2 | ↳ Bewilligungsverfahren, Auflageprojekt | Projekt bewilligt, Kosten und Termine verifiziert, Baukredit genehmigt | TRUE |
| 4 |  | 1 | Ausschreibung | Vergabereife erreicht | TRUE |
| 41 | 4 | 2 | ↳ Ausschreibung, Offertvergleich, Vergabeantrag | Vergabereife erreicht | TRUE |
| 5 |  | 1 | Realisierung | Bauwerk erstellt und in Betrieb genommen | TRUE |
| 51 | 5 | 2 | ↳ Ausführungsprojekt | Ausführungsreife erreicht | TRUE |
| 52 | 5 | 2 | ↳ Ausführung | Bauwerk gemäss Pflichtenheft und Vertrag erstellt | TRUE |
| 53 | 5 | 2 | ↳ Inbetriebnahme, Abschluss | Bauwerk übernommen und in Betrieb genommen, Schlussabrechnung abgenommen, Mängel behoben | TRUE |
| 6 |  | 1 | Bewirtschaftung | Betrieb sichergestellt und optimiert, Gebrauchstauglichkeit aufrechterhalten | TRUE |
| 61 | 6 | 2 | ↳ Betrieb | Betrieb sichergestellt und optimiert | TRUE |
| 62 | 6 | 2 | ↳ Erhaltung | Gebrauchstauglichkeit und Wert des Bauwerks für definierten Zeitraum aufrechterhalten | TRUE |

---

## BKP-Codes (`dim_bkp_codes`)

_425 Einträge — Baukostenplan-Positionen mit Collar-Klassifikation_

**Spalten:** `code` · `parent_code` · `ebene` (1–4) · `bezeichnung` · `BC` (blue_collar) · `WC` (white_collar) · `R` (relevant) · `bemerkungen`

| code | ebene | bezeichnung | BC | WC | R | bemerkungen |
|---|---|---|---|---|---|---|
| `0` | 1 | Grundstück | — | — | — | Reine Kostenposition |
| `00` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Vorstudien | — | ✓ | ✓ | Machbarkeitsstudien, Gutachten |
| `001` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Studien zur Grundstückbeurteilung, Machbarkeitsstudie | — | ✓ | ✓ |  |
| `002` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Vermessung, Vermarchung | — | ✓ | ✓ | Geometer |
| `003` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Geotechnische Gutachten | — | ✓ | ✓ | Geologe, Geotechniker |
| `004` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Quartierplankosten, Richtplankosten | — | ✓ | — |  |
| `005` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Provisorische Baugespanne | — | — | — |  |
| `006` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Umweltverträglichkeitsprüfung | — | ✓ | ✓ | Umweltingenieur |
| `01` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Grundstück- bzw. Baurechterwerb | — | — | — |  |
| `011` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundstückerwerb | — | — | — |  |
| `012` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baurechterwerb | — | — | — |  |
| `013` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Brandmauereinkauf | — | — | — |  |
| `018` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanierung Altlasten | ✓ | ✓ | ✓ | Altlastensanierung |
| `02` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Nebenkosten Grundstückerwerb | — | — | — |  |
| `021` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Handänderungssteuer | — | — | — |  |
| `022` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Notariatskosten | — | — | — |  |
| `023` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundbuchgebühren | — | — | — |  |
| `024` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Anwaltskosten, Gerichtskosten | — | — | — |  |
| `025` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Vermittlungsprovisionen | — | — | — |  |
| `03` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Abfindungen, Servitute, Beiträge | — | — | — |  |
| `031` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Inkonvenienzentschädigungen | — | — | — |  |
| `032` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Abfindungen an Mieter und Pächter | — | — | — |  |
| `033` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Errichtung von Servituten | — | — | — |  |
| `034` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ablösung von Servituten | — | — | — |  |
| `035` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wirtschaftspatente | — | — | — |  |
| `036` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Beiträge Melioration | — | — | — |  |
| `037` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Beiträge Güterzusammenlegung | — | — | — |  |
| `038` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Perimeterbeiträge | — | — | — |  |
| `04` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Finanzierung vor Baubeginn | — | — | — |  |
| `041` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Errichten von Hypotheken auf Grundstück | — | — | — |  |
| `042` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Hypothekarzinsen | — | — | — |  |
| `043` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baurechtszinsen | — | — | — |  |
| `044` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bankzinsen | — | — | — |  |
| `045` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Eigenkapitalzinsen | — | — | — |  |
| `046` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundstücksteuern | — | — | — |  |
| `048` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Versicherungen bis Baubeginn | — | — | — |  |
| `05` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Erschliessung Leitungen (ausserhalb Grundstück) | ✓ | ✓ | ✓ |  |
| `051` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erdarbeiten | ✓ | — | ✓ | Tiefbau |
| `052` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kanalisationsleitungen | ✓ | — | ✓ |  |
| `053` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroleitungen | ✓ | — | ✓ |  |
| `054` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Heizungs-, Lüftungs-, Klima-, Kälteleitungen | ✓ | — | ✓ |  |
| `055` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärleitungen | ✓ | — | ✓ |  |
| `056` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Nebenarbeiten | ✓ | — | ✓ |  |
| `06` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Erschliessung Verkehrsanlagen (ausserhalb Grundstück) | ✓ | ✓ | ✓ |  |
| `061` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Strassen | ✓ | ✓ | ✓ | Strassenbau |
| `062` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bahn | ✓ | ✓ | ✓ | Gleisbau |
| `063` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schiff | — | — | — | Selten relevant |
| `09` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Grundstück) | — | ✓ | ✓ |  |
| `091` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `092` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `093` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `094` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `095` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `096` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `1` | 1 | Vorbereitungsarbeiten | ✓ | ✓ | ✓ |  |
| `10` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Bestandesaufnahmen, Baugrunduntersuchungen | — | ✓ | ✓ |  |
| `101` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bestandesaufnahmen | — | ✓ | ✓ |  |
| `102` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrunduntersuchungen | — | ✓ | ✓ | Geotechniker |
| `103` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundwassererhebungen | — | ✓ | ✓ |  |
| `11` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Räumungen, Terrainvorbereitungen | ✓ | — | ✓ |  |
| `111` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Rodungen | ✓ | — | ✓ |  |
| `112` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Abbrüche | ✓ | — | ✓ | Abbruchunternehmer |
| `113` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Demontagen | ✓ | — | ✓ |  |
| `114` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erdbewegungen | ✓ | — | ✓ |  |
| `115` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bohr- und Schneidarbeiten | ✓ | — | ✓ |  |
| `12` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Sicherungen, Provisorien | ✓ | ✓ | ✓ |  |
| `121` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sicherung vorhandener Anlagen | ✓ | ✓ | ✓ |  |
| `122` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Provisorien | ✓ | — | ✓ |  |
| `123` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Unterfangungen | ✓ | ✓ | ✓ | Spezialtiefbau |
| `124` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Instandsetzungsarbeiten | ✓ | — | ✓ |  |
| `13` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Gemeinsame Baustelleneinrichtung | ✓ | ✓ | ✓ |  |
| `131` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Abschrankungen | ✓ | — | ✓ |  |
| `132` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Zufahrten, Plätze | ✓ | — | ✓ |  |
| `133` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Büro Bauleitung | — | ✓ | ✓ |  |
| `134` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Unterkünfte, Verpflegungseinrichtungen | ✓ | — | ✓ |  |
| `135` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Provisorische Installationen | ✓ | — | ✓ |  |
| `136` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kosten für Energie, Wasser und dgl. | — | — | — | Kostenposition |
| `137` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Provisorische Abschlüsse und Abdeckungen | ✓ | — | ✓ |  |
| `138` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauabfälle Sortierung | ✓ | — | ✓ |  |
| `14` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Anpassungen an bestehende Bauten | ✓ | ✓ | ✓ |  |
| `141` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Terraingestaltung, Rohbau 1 | ✓ | — | ✓ |  |
| `142` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 2 | ✓ | — | ✓ |  |
| `143` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroanlagen | ✓ | ✓ | ✓ |  |
| `144` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK- und Kälteanlagen | ✓ | ✓ | ✓ |  |
| `145` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäranlagen | ✓ | ✓ | ✓ |  |
| `146` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen | ✓ | ✓ | ✓ |  |
| `147` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 1 | ✓ | — | ✓ |  |
| `148` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 2 | ✓ | — | ✓ |  |
| `15` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Anpassungen bestehende Erschliessungsleitungen | ✓ | — | ✓ |  |
| `151` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erdarbeiten | ✓ | — | ✓ |  |
| `152` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kanalisationsleitungen | ✓ | — | ✓ |  |
| `153` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroleitungen | ✓ | — | ✓ |  |
| `154` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Kälteleitungen | ✓ | — | ✓ |  |
| `155` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärleitungen | ✓ | — | ✓ |  |
| `156` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Nebenarbeiten | ✓ | — | ✓ |  |
| `16` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Anpassungen bestehende Verkehrsanlagen | ✓ | ✓ | ✓ |  |
| `161` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Strassen | ✓ | ✓ | ✓ |  |
| `162` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bahn | ✓ | ✓ | ✓ |  |
| `163` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schiff | — | — | — |  |
| `17` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Spezielle Fundationen, Baugrubensicherung | ✓ | ✓ | ✓ | Spezialtiefbau |
| `171` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Pfähle | ✓ | ✓ | ✓ |  |
| `172` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrubenabschlüsse | ✓ | ✓ | ✓ |  |
| `173` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Aussteifungen | ✓ | ✓ | ✓ |  |
| `174` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Anker | ✓ | ✓ | ✓ |  |
| `175` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundwasserabdichtungen | ✓ | ✓ | ✓ |  |
| `176` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wasserhaltung | ✓ | ✓ | ✓ |  |
| `177` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrundverbesserungen | ✓ | ✓ | ✓ |  |
| `178` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Nebenarbeiten | ✓ | — | ✓ |  |
| `19` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Vorbereitungsarbeiten) | — | ✓ | ✓ |  |
| `191` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `192` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `193` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `194` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `195` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `196` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `2` | 1 | Gebäude | ✓ | ✓ | ✓ | Kernbereich |
| `20` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrube | ✓ | — | ✓ |  |
| `201` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrubenaushub | ✓ | — | ✓ |  |
| `21` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 1 | ✓ | ✓ | ✓ | Baumeisterarbeiten |
| `211` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baumeisterarbeiten | ✓ | — | ✓ |  |
| `211.1` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gerüste | ✓ | — | ✓ | Gerüstbauer |
| `212` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau Beton/Mauerwerk | ✓ | — | ✓ |  |
| `213` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau in Stahl | ✓ | — | ✓ | Stahlbau |
| `214` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau in Holz | ✓ | — | ✓ | Holzbau |
| `215` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau Leichtkonstruktionen | ✓ | — | ✓ |  |
| `216` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Natur- und Kunststeinarbeiten | ✓ | — | ✓ |  |
| `217` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schutzraumabschlüsse | ✓ | — | ✓ |  |
| `22` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 2 | ✓ | ✓ | ✓ | Gebäudehülle |
| `221` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fenster, Aussentüren, Tore | ✓ | ✓ | ✓ | Fensterbau + Fassadenplaner |
| `222` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spenglerarbeiten | ✓ | — | ✓ | Spengler |
| `223` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Blitzschutz | ✓ | — | ✓ |  |
| `224` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bedachungsarbeiten | ✓ | — | ✓ | Dachdecker |
| `225` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezielle Dichtungen und Dämmungen | ✓ | ✓ | ✓ | Abdichter + Bauphysiker |
| `226` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fassadenputze | ✓ | — | ✓ | Fassadenbau |
| `227` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Äussere Oberflächenbehandlungen | ✓ | — | ✓ |  |
| `228` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Äussere Abschlüsse, Sonnenschutz | ✓ | — | ✓ |  |
| `23` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroanlagen | ✓ | ✓ | ✓ |  |
| `231` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Apparate Starkstrom | ✓ | ✓ | ✓ |  |
| `232` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Starkstrominstallationen | ✓ | — | ✓ | Elektroinstallateur |
| `233` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Leuchten und Lampen | ✓ | — | ✓ |  |
| `234` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Energieverbraucher | ✓ | — | ✓ |  |
| `235` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Apparate Schwachstrom | ✓ | ✓ | ✓ |  |
| `236` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schwachstrominstallationen | ✓ | — | ✓ |  |
| `237` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomation | ✓ | ✓ | ✓ | GA-Ingenieur + GA-Monteur |
| `238` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauprovisorien | ✓ | — | ✓ |  |
| `24` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Heizungs-, Lüftungs-, Klimaanlagen | ✓ | ✓ | ✓ | HLK |
| `241` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Zulieferung Energieträger, Lagerung | ✓ | — | ✓ |  |
| `242` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wärmeerzeugung | ✓ | ✓ | ✓ |  |
| `243` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wärmeverteilung | ✓ | ✓ | ✓ |  |
| `244` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Lüftungsanlagen | ✓ | ✓ | ✓ | Lüftungsmonteur/-planer |
| `245` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Klimaanlagen | ✓ | ✓ | ✓ | Kältemonteur/-planer |
| `246` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kälteanlagen | ✓ | ✓ | ✓ |  |
| `247` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialanlagen | ✓ | ✓ | ✓ |  |
| `248` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Dämmungen HLK-Installationen | ✓ | — | ✓ | Isolierspengler |
| `25` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäranlagen | ✓ | ✓ | ✓ |  |
| `251` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Allgemeine Sanitärapparate | ✓ | — | ✓ | Sanitärinstallateur |
| `252` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezielle Sanitärapparate | ✓ | — | ✓ |  |
| `253` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäre Ver-/Entsorgungsapparate | ✓ | — | ✓ |  |
| `254` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärleitungen | ✓ | — | ✓ |  |
| `255` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Dämmungen Sanitärinstallationen | ✓ | — | ✓ |  |
| `256` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärinstallationselemente | ✓ | — | ✓ |  |
| `257` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektro- und Pneumatiktafeln | ✓ | — | ✓ |  |
| `258` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kücheneinrichtungen | ✓ | — | ✓ | Küchenbauer |
| `26` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen | ✓ | — | ✓ |  |
| `261` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Aufzüge | ✓ | — | ✓ | Aufzugsmonteur |
| `262` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fahrtreppen, Fahrsteige | ✓ | — | ✓ |  |
| `263` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fassadenreinigungsanlagen | ✓ | — | ✓ |  |
| `264` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sonstige Förderanlagen | ✓ | — | ✓ |  |
| `265` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Hebeeinrichtungen | ✓ | — | ✓ |  |
| `266` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Parkieranlagen | ✓ | — | ✓ |  |
| `27` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 1 | ✓ | — | ✓ |  |
| `271` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gipserarbeiten | ✓ | — | ✓ | Gipser |
| `272` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Metallbauarbeiten | ✓ | — | ✓ | Metallbauer/Schlosser |
| `273` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schreinerarbeiten | ✓ | — | ✓ | Schreiner |
| `274` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialverglasungen (innen) | ✓ | — | ✓ |  |
| `275` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schliessanlagen | ✓ | — | ✓ |  |
| `276` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innere Abschlüsse | ✓ | — | ✓ |  |
| `277` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elementwände | ✓ | — | ✓ |  |
| `28` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 2 | ✓ | — | ✓ |  |
| `281` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge | ✓ | — | ✓ | Bodenleger |
| `281.0` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Unterlagsböden | ✓ | — | ✓ |  |
| `281.1` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fugenlose Bodenbeläge | ✓ | — | ✓ |  |
| `281.2` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge Kunststoffe/Textilien | ✓ | — | ✓ |  |
| `281.4` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge Naturstein | ✓ | — | ✓ |  |
| `281.5` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge Kunststein | ✓ | — | ✓ |  |
| `281.6` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge Plattenarbeiten | ✓ | — | ✓ | Plattenleger |
| `281.7` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge in Holz | ✓ | — | ✓ | Parkettleger |
| `281.8` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Doppelböden | ✓ | — | ✓ |  |
| `282` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandbeläge, Wandbekleidungen | ✓ | — | ✓ |  |
| `282.0` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fugenlose Wandbeläge | ✓ | — | ✓ |  |
| `282.1` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Tapezierarbeiten | ✓ | — | ✓ | Maler/Tapezierer |
| `282.2` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandverkleidungen Naturstein | ✓ | — | ✓ |  |
| `282.3` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandverkleidungen Kunststein | ✓ | — | ✓ |  |
| `282.4` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandbeläge Plattenarbeiten | ✓ | — | ✓ |  |
| `282.5` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandverkleidung Holz/Holzwerkstoffe | ✓ | — | ✓ |  |
| `282.6` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandverkleidung Kunststoffe/Textilien | ✓ | — | ✓ |  |
| `283` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenbekleidungen | ✓ | — | ✓ |  |
| `283.1` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Metall | ✓ | — | ✓ |  |
| `283.2` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Gips | ✓ | — | ✓ |  |
| `283.3` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Mineralfasern | ✓ | — | ✓ |  |
| `283.4` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Holz/Holzwerkstoffe | ✓ | — | ✓ |  |
| `283.5` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Kunststoffe/Textilien | ✓ | — | ✓ |  |
| `283.6` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Metall Paneele/Lamellen | ✓ | — | ✓ |  |
| `283.7` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenverkleidungen Metall Raster | ✓ | — | ✓ |  |
| `284` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Hafnerarbeiten | ✓ | — | ✓ | Hafner/Ofenbauer |
| `285` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innere Oberflächenbehandlungen | ✓ | — | ✓ | Maler |
| `286` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauaustrocknung | ✓ | — | ✓ |  |
| `287` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baureinigung | ✓ | — | ✓ |  |
| `288` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gärtnerarbeiten (Gebäude) | ✓ | — | ✓ |  |
| `29` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Gebäude) | — | ✓ | ✓ |  |
| `291` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `292` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `293` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `294` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `295` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `296` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `296.0` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Geometer | — | ✓ | ✓ |  |
| `296.2` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innenarchitekt | — | ✓ | ✓ |  |
| `296.3` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauphysiker | — | ✓ | ✓ |  |
| `296.4` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Akustiker | — | ✓ | ✓ |  |
| `296.5` | 4 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Landschaftsarchitekt | — | ✓ | ✓ |  |
| `298` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomationsingenieur | — | ✓ | ✓ |  |
| `3` | 1 | Betriebseinrichtungen | ✓ | ✓ | ✓ | Industrie-/Gewerbebauten |
| `30` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrube | ✓ | — | ✓ |  |
| `301` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrubenaushub | ✓ | — | ✓ |  |
| `31` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 1 | ✓ | — | ✓ |  |
| `311` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baumeisterarbeiten | ✓ | — | ✓ |  |
| `312` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau Beton/Mauerwerk | ✓ | — | ✓ |  |
| `313` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau in Stahl | ✓ | — | ✓ |  |
| `314` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau in Holz | ✓ | — | ✓ |  |
| `315` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Montagebau Leichtkonstruktionen | ✓ | — | ✓ |  |
| `316` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Natur- und Kunststeinarbeiten | ✓ | — | ✓ |  |
| `317` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schutzraumabschlüsse | ✓ | — | ✓ |  |
| `32` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 2 | ✓ | — | ✓ |  |
| `321` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fenster, Aussentüren, Tore | ✓ | ✓ | ✓ |  |
| `322` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spenglerarbeiten | ✓ | — | ✓ |  |
| `323` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Blitzschutz | ✓ | — | ✓ |  |
| `324` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bedachungsarbeiten | ✓ | — | ✓ |  |
| `325` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezielle Dichtungen und Dämmungen | ✓ | ✓ | ✓ |  |
| `326` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fassadenputze | ✓ | — | ✓ |  |
| `327` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Äussere Oberflächenbehandlungen | ✓ | — | ✓ |  |
| `328` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Äussere Abschlüsse, Sonnenschutz | ✓ | — | ✓ |  |
| `33` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroanlagen | ✓ | ✓ | ✓ |  |
| `331` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Apparate Starkstrom | ✓ | ✓ | ✓ |  |
| `332` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Starkstrominstallationen | ✓ | — | ✓ |  |
| `333` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Leuchten und Lampen | ✓ | — | ✓ |  |
| `334` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Energieverbraucher | ✓ | — | ✓ |  |
| `335` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Apparate Schwachstrom | ✓ | ✓ | ✓ |  |
| `336` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schwachstrominstallationen | ✓ | — | ✓ |  |
| `337` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomation | ✓ | ✓ | ✓ |  |
| `338` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauprovisorium | ✓ | — | ✓ |  |
| `34` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ HLK- und Kälteanlagen | ✓ | ✓ | ✓ |  |
| `341` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Zulieferung Energieträger, Lagerung | ✓ | — | ✓ |  |
| `342` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wärmeerzeugung | ✓ | ✓ | ✓ |  |
| `343` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wärmeverteilung | ✓ | ✓ | ✓ |  |
| `344` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Lüftungsanlagen | ✓ | ✓ | ✓ |  |
| `345` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Klimaanlagen | ✓ | ✓ | ✓ |  |
| `346` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kälteanlagen | ✓ | ✓ | ✓ |  |
| `347` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialanlagen | ✓ | ✓ | ✓ |  |
| `348` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Dämmungen HLK-Installationen | ✓ | — | ✓ |  |
| `35` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäranlagen | ✓ | ✓ | ✓ |  |
| `351` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Allgemeine Sanitärapparate | ✓ | — | ✓ |  |
| `352` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezielle Sanitärapparate | ✓ | — | ✓ |  |
| `353` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäre Ver-/Entsorgungsapparate | ✓ | — | ✓ |  |
| `354` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärleitungen | ✓ | — | ✓ |  |
| `355` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Dämmungen Sanitärinstallationen | ✓ | — | ✓ |  |
| `356` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärinstallationselemente | ✓ | — | ✓ |  |
| `357` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektro- und Pneumatiktafeln | ✓ | — | ✓ |  |
| `358` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kücheneinrichtungen | ✓ | — | ✓ |  |
| `36` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen, Lageranlagen | ✓ | — | ✓ |  |
| `361` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Aufzüge | ✓ | — | ✓ |  |
| `362` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fahrtreppen, Fahrsteige | ✓ | — | ✓ |  |
| `364` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sonstige Förderanlagen | ✓ | — | ✓ |  |
| `365` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Hebeeinrichtungen | ✓ | — | ✓ |  |
| `366` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Parkieranlagen | ✓ | — | ✓ |  |
| `368` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sonstige Lageranlagen | ✓ | — | ✓ |  |
| `37` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 1 | ✓ | — | ✓ |  |
| `371` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gipserarbeiten | ✓ | — | ✓ |  |
| `372` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Metallbauarbeiten | ✓ | — | ✓ |  |
| `373` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schreinerarbeiten | ✓ | — | ✓ |  |
| `374` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialverglasungen (innere) | ✓ | — | ✓ |  |
| `375` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schliessanlagen | ✓ | — | ✓ |  |
| `376` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innere Abschlüsse | ✓ | — | ✓ |  |
| `377` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elementwände | ✓ | — | ✓ |  |
| `38` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 2 | ✓ | — | ✓ |  |
| `381` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bodenbeläge | ✓ | — | ✓ |  |
| `382` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wandbeläge, Wandbekleidungen | ✓ | — | ✓ |  |
| `383` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Deckenbekleidungen | ✓ | — | ✓ |  |
| `384` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Hafnerarbeiten | ✓ | — | ✓ |  |
| `385` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innere Oberflächenbehandlungen | ✓ | — | ✓ |  |
| `386` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauaustrocknung | ✓ | — | ✓ |  |
| `387` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baureinigung | ✓ | — | ✓ |  |
| `388` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gärtnerarbeiten (Betriebseinrichtungen) | ✓ | — | ✓ |  |
| `39` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Betriebseinrichtungen) | — | ✓ | ✓ |  |
| `391` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `392` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `393` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `394` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `395` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `396` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `398` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomationsingenieur | — | ✓ | ✓ |  |
| `4` | 1 | Umgebung | ✓ | ✓ | ✓ |  |
| `40` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Terraingestaltung | ✓ | — | ✓ |  |
| `401` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erdbewegungen | ✓ | — | ✓ |  |
| `41` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Roh- und Ausbauarbeiten | ✓ | — | ✓ |  |
| `411` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baumeisterarbeiten | ✓ | — | ✓ |  |
| `413` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Übriger Rohbau 1 | ✓ | — | ✓ |  |
| `414` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Rohbau 2 | ✓ | — | ✓ |  |
| `415` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 1 | ✓ | — | ✓ |  |
| `416` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau 2 | ✓ | — | ✓ |  |
| `42` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Gartenanlagen | ✓ | ✓ | ✓ | Landschaftsgärtner |
| `421` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gärtnerarbeiten | ✓ | — | ✓ |  |
| `422` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Einfriedungen | ✓ | — | ✓ |  |
| `423` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausstattungen, Geräte | ✓ | — | ✓ |  |
| `424` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spiel- und Sportplätze | ✓ | — | ✓ |  |
| `44` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Installationen (Umgebung) | ✓ | ✓ | ✓ |  |
| `443` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroanlagen | ✓ | ✓ | ✓ |  |
| `444` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Kälteanlagen | ✓ | ✓ | ✓ |  |
| `445` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäranlagen | ✓ | ✓ | ✓ |  |
| `446` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen | ✓ | ✓ | ✓ |  |
| `45` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Erschliessung Leitungen (innerhalb Grundstück) | ✓ | — | ✓ |  |
| `451` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erdarbeiten | ✓ | — | ✓ |  |
| `452` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kanalisationsleitungen | ✓ | — | ✓ |  |
| `453` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroleitungen | ✓ | — | ✓ |  |
| `454` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Kälteleitungen | ✓ | — | ✓ |  |
| `455` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitärleitungen | ✓ | — | ✓ |  |
| `456` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Nebenarbeiten | ✓ | — | ✓ |  |
| `46` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Kleinere Trassenbauten | ✓ | ✓ | ✓ | Tiefbau |
| `461` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Erd- und Unterbau | ✓ | — | ✓ |  |
| `462` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Kleine Kunstbauten | ✓ | ✓ | ✓ |  |
| `463` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Oberbau | ✓ | — | ✓ |  |
| `464` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Entwässerung | ✓ | — | ✓ |  |
| `465` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Werkleitungen und Kanalisationen | ✓ | — | ✓ |  |
| `468` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau | ✓ | — | ✓ |  |
| `47` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Kleinere Kunstbauten | ✓ | ✓ | ✓ |  |
| `471` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baugrube | ✓ | — | ✓ |  |
| `472` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Tragkonstruktion | ✓ | ✓ | ✓ |  |
| `473` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Oberbau | ✓ | — | ✓ |  |
| `474` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Entwässerung | ✓ | — | ✓ |  |
| `475` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Werkleitungen und Kanalisationen | ✓ | — | ✓ |  |
| `477` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen | ✓ | — | ✓ |  |
| `478` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau | ✓ | — | ✓ |  |
| `48` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Kleinere Untertagbauten | ✓ | ✓ | ✓ | Tunnelbau |
| `481` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Vortrieb | ✓ | — | ✓ | Mineur |
| `482` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Auskleidung, Gewölbe | ✓ | — | ✓ |  |
| `483` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Oberbau | ✓ | — | ✓ |  |
| `484` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Entwässerung und Wasserversorgung | ✓ | — | ✓ |  |
| `485` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Werkleitungen und Kanalisationen | ✓ | — | ✓ |  |
| `487` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Transportanlagen | ✓ | — | ✓ |  |
| `488` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ausbau | ✓ | — | ✓ |  |
| `49` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Umgebung) | — | ✓ | ✓ |  |
| `491` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `492` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `493` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `494` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `495` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `496` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `498` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomationsingenieur | — | ✓ | ✓ |  |
| `5` | 1 | Baunebenkosten und Übergangskonten | — | ✓ | ✓ |  |
| `50` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Wettbewerbskosten | — | ✓ | ✓ |  |
| `501` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekturwettbewerbe | — | ✓ | ✓ |  |
| `502` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Ingenieurwettbewerbe | — | ✓ | ✓ |  |
| `503` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wettbewerbe Umgebungsgestaltung | — | ✓ | ✓ |  |
| `504` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Wettbewerbe künstlerische Gestaltung | — | ✓ | ✓ |  |
| `505` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Städtebaulicher Wettbewerb | — | ✓ | ✓ |  |
| `506` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Innenarchitekturwettbewerb | — | ✓ | ✓ |  |
| `51` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Bewilligungen, Gebühren | — | ✓ | ✓ |  |
| `511` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bewilligungen, Baugespann | — | ✓ | ✓ |  |
| `512` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Anschlussgebühren | — | — | — |  |
| `52` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Muster, Modelle, Dokumentation | — | ✓ | ✓ |  |
| `521` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Muster, Materialprüfungen | — | ✓ | ✓ |  |
| `522` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Modelle | — | ✓ | ✓ |  |
| `523` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Fotos | — | — | — |  |
| `524` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Vervielfältigungen, Plankopien | — | — | — |  |
| `525` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Dokumentation | — | ✓ | ✓ |  |
| `53` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Versicherungen | — | — | — |  |
| `531` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauzeitversicherungen | — | — | — |  |
| `532` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialversicherungen | — | — | — |  |
| `533` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Selbstbehalt Schadenfälle | — | — | — |  |
| `54` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Finanzierung ab Baubeginn | — | — | — |  |
| `541` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Errichten von Hypotheken | — | — | — |  |
| `542` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baukreditzinsen, Bankspesen | — | — | — |  |
| `543` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baurechtszinsen | — | — | — |  |
| `545` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Eigenkapitalzinsen | — | — | — |  |
| `546` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Liegenschaftensteuer Bauzeit | — | — | — |  |
| `548` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Rückvergütungen | — | — | — |  |
| `55` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Bauherrenleistungen | — | ✓ | ✓ | BHV/Projektleitung |
| `557` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Betriebsplanung | — | ✓ | ✓ |  |
| `558` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Projektleitung, Projektbegleitung | — | ✓ | ✓ | Projektleiter BHV |
| `56` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Übrige Baunebenkosten | — | — | — |  |
| `561` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bewachung durch Dritte | — | — | — |  |
| `562` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Nachbar-/Mieterentschädigungen | — | — | — |  |
| `563` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Miete von fremdem Grund | — | — | — |  |
| `564` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gutachten | — | ✓ | ✓ |  |
| `565` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Reisespesen | — | — | — |  |
| `566` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Grundsteinlegung, Aufrichte, Einweihung | — | — | — |  |
| `567` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Anwaltskosten, Gerichtskosten | — | — | — |  |
| `568` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Baureklame | — | — | — |  |
| `57` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Mehrwertsteuer (MWSt) | — | — | — |  |
| `58` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Übergangskonten Rückstellungen/Reserven | — | — | — |  |
| `59` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Übergangskonten Honorare | — | ✓ | ✓ |  |
| `591` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `592` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Bauingenieur | — | ✓ | ✓ |  |
| `593` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `594` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ HLK-Ingenieur | — | ✓ | ✓ |  |
| `595` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sanitäringenieur | — | ✓ | ✓ |  |
| `596` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |
| `598` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Gebäudeautomationsingenieur | — | ✓ | ✓ |  |
| `9` | 1 | Ausstattung | ✓ | ✓ | ✓ |  |
| `90` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Möbel | ✓ | — | ✓ | Schreiner |
| `901` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Garderobeneinrichtungen etc. | ✓ | — | ✓ |  |
| `902` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Sporteinrichtungen | ✓ | — | ✓ |  |
| `908` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Schutzraumausstattungen | ✓ | — | ✓ |  |
| `91` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Beleuchtungskörper | ✓ | ✓ | ✓ |  |
| `92` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Textilien | ✓ | — | ✓ |  |
| `921` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Vorhänge und Innendekorationsarbeiten | ✓ | — | ✓ | Raumausstatter |
| `93` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Geräte, Apparate | ✓ | — | ✓ |  |
| `94` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Kleininventar | — | — | — |  |
| `96` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Transportmittel | — | — | — |  |
| `97` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Verbrauchsmaterial | — | — | — |  |
| `98` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Künstlerischer Schmuck | ✓ | — | ✓ | Kunsthandwerker |
| `99` | 2 | &nbsp;&nbsp;&nbsp;&nbsp;↳ Honorare (Ausstattung) | — | ✓ | ✓ |  |
| `991` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Architekt | — | ✓ | ✓ |  |
| `993` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Elektroingenieur | — | ✓ | ✓ |  |
| `996` | 3 | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ Spezialisten | — | ✓ | ✓ |  |

---

## Verknüpfung BKP ↔ SIA-Phasen (`bridge_bkp_sia_phases`)

_1465 Verknüpfungen — welche SIA-Phasen sind für welchen BKP-Code relevant_

| BKP-Code | Bezeichnung | Verknüpfte SIA-Phasen |
|---|---|---|
| `00` | Vorstudien | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `01` | Grundstück- bzw. Baurechterwerb | `11` Bedürfnisformulierung, Lösungsstrategien |
| `02` | Nebenkosten Grundstückerwerb | `11` Bedürfnisformulierung, Lösungsstrategien |
| `03` | Abfindungen, Servitute, Beiträge | `11` Bedürfnisformulierung, Lösungsstrategien |
| `04` | Finanzierung vor Baubeginn | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `05` | Erschliessung Leitungen (ausserhalb Grundstück) | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `06` | Erschliessung Verkehrsanlagen (ausserhalb Grundstück) | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `09` | Honorare (Grundstück) | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `10` | Bestandesaufnahmen, Baugrunduntersuchungen | `21` Projektdefinition, Machbarkeitsstudie |
| `11` | Räumungen, Terrainvorbereitungen | `52` Ausführung |
| `12` | Sicherungen, Provisorien | `52` Ausführung |
| `13` | Gemeinsame Baustelleneinrichtung | `52` Ausführung |
| `14` | Anpassungen an bestehende Bauten | `52` Ausführung |
| `15` | Anpassungen bestehende Erschliessungsleitungen | `52` Ausführung |
| `16` | Anpassungen bestehende Verkehrsanlagen | `52` Ausführung |
| `17` | Spezielle Fundationen, Baugrubensicherung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `19` | Honorare (Vorbereitungsarbeiten) | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `20` | Baugrube | `52` Ausführung |
| `21` | Rohbau 1 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `22` | Rohbau 2 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `23` | Elektroanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `24` | Heizungs-, Lüftungs-, Klimaanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `25` | Sanitäranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `26` | Transportanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `27` | Ausbau 1 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `28` | Ausbau 2 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `29` | Honorare (Gebäude) | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `30` | Baugrube | `52` Ausführung |
| `31` | Rohbau 1 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `32` | Rohbau 2 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `33` | Elektroanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `34` | HLK- und Kälteanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `35` | Sanitäranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `36` | Transportanlagen, Lageranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `37` | Ausbau 1 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `38` | Ausbau 2 | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `39` | Honorare (Betriebseinrichtungen) | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `40` | Terraingestaltung | `52` Ausführung |
| `41` | Roh- und Ausbauarbeiten | `52` Ausführung |
| `42` | Gartenanlagen | `51` Ausführungsprojekt<br>`52` Ausführung |
| `44` | Installationen (Umgebung) | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `45` | Erschliessung Leitungen (innerhalb Grundstück) | `52` Ausführung |
| `46` | Kleinere Trassenbauten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `47` | Kleinere Kunstbauten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `48` | Kleinere Untertagbauten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `49` | Honorare (Umgebung) | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `50` | Wettbewerbskosten | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `51` | Bewilligungen, Gebühren | `33` Bewilligungsverfahren, Auflageprojekt |
| `52` | Muster, Modelle, Dokumentation | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `53` | Versicherungen | `52` Ausführung |
| `54` | Finanzierung ab Baubeginn | `52` Ausführung |
| `55` | Bauherrenleistungen | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss<br>`61` Betrieb |
| `56` | Übrige Baunebenkosten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `57` | Mehrwertsteuer (MWSt) | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss<br>`61` Betrieb<br>`62` Erhaltung |
| `58` | Übergangskonten Rückstellungen/Reserven | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `59` | Übergangskonten Honorare | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `90` | Möbel | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `91` | Beleuchtungskörper | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `92` | Textilien | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `93` | Geräte, Apparate | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `94` | Kleininventar | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss<br>`61` Betrieb |
| `96` | Transportmittel | `52` Ausführung |
| `97` | Verbrauchsmaterial | `52` Ausführung<br>`61` Betrieb |
| `98` | Künstlerischer Schmuck | `52` Ausführung |
| `99` | Honorare (Ausstattung) | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `001` | Studien zur Grundstückbeurteilung, Machbarkeitsstudie | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `002` | Vermessung, Vermarchung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `003` | Geotechnische Gutachten | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `004` | Quartierplankosten, Richtplankosten | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `005` | Provisorische Baugespanne | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `006` | Umweltverträglichkeitsprüfung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `011` | Grundstückerwerb | `11` Bedürfnisformulierung, Lösungsstrategien |
| `012` | Baurechterwerb | `11` Bedürfnisformulierung, Lösungsstrategien |
| `013` | Brandmauereinkauf | `11` Bedürfnisformulierung, Lösungsstrategien |
| `018` | Sanierung Altlasten | `11` Bedürfnisformulierung, Lösungsstrategien |
| `021` | Handänderungssteuer | `11` Bedürfnisformulierung, Lösungsstrategien |
| `022` | Notariatskosten | `11` Bedürfnisformulierung, Lösungsstrategien |
| `023` | Grundbuchgebühren | `11` Bedürfnisformulierung, Lösungsstrategien |
| `024` | Anwaltskosten, Gerichtskosten | `11` Bedürfnisformulierung, Lösungsstrategien |
| `025` | Vermittlungsprovisionen | `11` Bedürfnisformulierung, Lösungsstrategien |
| `031` | Inkonvenienzentschädigungen | `11` Bedürfnisformulierung, Lösungsstrategien |
| `032` | Abfindungen an Mieter und Pächter | `11` Bedürfnisformulierung, Lösungsstrategien |
| `033` | Errichtung von Servituten | `11` Bedürfnisformulierung, Lösungsstrategien |
| `034` | Ablösung von Servituten | `11` Bedürfnisformulierung, Lösungsstrategien |
| `035` | Wirtschaftspatente | `11` Bedürfnisformulierung, Lösungsstrategien |
| `036` | Beiträge Melioration | `11` Bedürfnisformulierung, Lösungsstrategien |
| `037` | Beiträge Güterzusammenlegung | `11` Bedürfnisformulierung, Lösungsstrategien |
| `038` | Perimeterbeiträge | `11` Bedürfnisformulierung, Lösungsstrategien |
| `041` | Errichten von Hypotheken auf Grundstück | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `042` | Hypothekarzinsen | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `043` | Baurechtszinsen | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `044` | Bankzinsen | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `045` | Eigenkapitalzinsen | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `046` | Grundstücksteuern | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `048` | Versicherungen bis Baubeginn | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `051` | Erdarbeiten | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `052` | Kanalisationsleitungen | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `053` | Elektroleitungen | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `054` | Heizungs-, Lüftungs-, Klima-, Kälteleitungen | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `055` | Sanitärleitungen | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `056` | Nebenarbeiten | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `061` | Strassen | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `062` | Bahn | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `063` | Schiff | `32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `091` | Architekt | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `092` | Bauingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `093` | Elektroingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `094` | HLK-Ingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `095` | Sanitäringenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `096` | Spezialisten | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie |
| `101` | Bestandesaufnahmen | `21` Projektdefinition, Machbarkeitsstudie |
| `102` | Baugrunduntersuchungen | `21` Projektdefinition, Machbarkeitsstudie |
| `103` | Grundwassererhebungen | `21` Projektdefinition, Machbarkeitsstudie |
| `111` | Rodungen | `52` Ausführung |
| `112` | Abbrüche | `52` Ausführung |
| `113` | Demontagen | `52` Ausführung |
| `114` | Erdbewegungen | `52` Ausführung |
| `115` | Bohr- und Schneidarbeiten | `52` Ausführung |
| `121` | Sicherung vorhandener Anlagen | `52` Ausführung |
| `122` | Provisorien | `52` Ausführung |
| `123` | Unterfangungen | `52` Ausführung |
| `124` | Instandsetzungsarbeiten | `52` Ausführung |
| `131` | Abschrankungen | `52` Ausführung |
| `132` | Zufahrten, Plätze | `52` Ausführung |
| `133` | Büro Bauleitung | `52` Ausführung |
| `134` | Unterkünfte, Verpflegungseinrichtungen | `52` Ausführung |
| `135` | Provisorische Installationen | `52` Ausführung |
| `136` | Kosten für Energie, Wasser und dgl. | `52` Ausführung |
| `137` | Provisorische Abschlüsse und Abdeckungen | `52` Ausführung |
| `138` | Bauabfälle Sortierung | `52` Ausführung |
| `141` | Terraingestaltung, Rohbau 1 | `52` Ausführung |
| `142` | Rohbau 2 | `52` Ausführung |
| `143` | Elektroanlagen | `52` Ausführung |
| `144` | HLK- und Kälteanlagen | `52` Ausführung |
| `145` | Sanitäranlagen | `52` Ausführung |
| `146` | Transportanlagen | `52` Ausführung |
| `147` | Ausbau 1 | `52` Ausführung |
| `148` | Ausbau 2 | `52` Ausführung |
| `151` | Erdarbeiten | `52` Ausführung |
| `152` | Kanalisationsleitungen | `52` Ausführung |
| `153` | Elektroleitungen | `52` Ausführung |
| `154` | HLK-Kälteleitungen | `52` Ausführung |
| `155` | Sanitärleitungen | `52` Ausführung |
| `156` | Nebenarbeiten | `52` Ausführung |
| `161` | Strassen | `52` Ausführung |
| `162` | Bahn | `52` Ausführung |
| `163` | Schiff | `52` Ausführung |
| `171` | Pfähle | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `172` | Baugrubenabschlüsse | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `173` | Aussteifungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `174` | Anker | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `175` | Grundwasserabdichtungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `176` | Wasserhaltung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `177` | Baugrundverbesserungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `178` | Nebenarbeiten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `191` | Architekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `192` | Bauingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `193` | Elektroingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `194` | HLK-Ingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `195` | Sanitäringenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `196` | Spezialisten | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `201` | Baugrubenaushub | `52` Ausführung |
| `211` | Baumeisterarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `212` | Montagebau Beton/Mauerwerk | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `213` | Montagebau in Stahl | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `214` | Montagebau in Holz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `215` | Montagebau Leichtkonstruktionen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `216` | Natur- und Kunststeinarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `217` | Schutzraumabschlüsse | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `221` | Fenster, Aussentüren, Tore | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `222` | Spenglerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `223` | Blitzschutz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `224` | Bedachungsarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `225` | Spezielle Dichtungen und Dämmungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `226` | Fassadenputze | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `227` | Äussere Oberflächenbehandlungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `228` | Äussere Abschlüsse, Sonnenschutz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `231` | Apparate Starkstrom | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `232` | Starkstrominstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `233` | Leuchten und Lampen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `234` | Energieverbraucher | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `235` | Apparate Schwachstrom | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `236` | Schwachstrominstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `237` | Gebäudeautomation | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `238` | Bauprovisorien | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `241` | Zulieferung Energieträger, Lagerung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `242` | Wärmeerzeugung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `243` | Wärmeverteilung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `244` | Lüftungsanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `245` | Klimaanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `246` | Kälteanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `247` | Spezialanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `248` | Dämmungen HLK-Installationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `251` | Allgemeine Sanitärapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `252` | Spezielle Sanitärapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `253` | Sanitäre Ver-/Entsorgungsapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `254` | Sanitärleitungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `255` | Dämmungen Sanitärinstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `256` | Sanitärinstallationselemente | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `257` | Elektro- und Pneumatiktafeln | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `258` | Kücheneinrichtungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `261` | Aufzüge | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `262` | Fahrtreppen, Fahrsteige | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `263` | Fassadenreinigungsanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `264` | Sonstige Förderanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `265` | Hebeeinrichtungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `266` | Parkieranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `271` | Gipserarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `272` | Metallbauarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `273` | Schreinerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `274` | Spezialverglasungen (innen) | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `275` | Schliessanlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `276` | Innere Abschlüsse | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `277` | Elementwände | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281` | Bodenbeläge | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282` | Wandbeläge, Wandbekleidungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283` | Deckenbekleidungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `284` | Hafnerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `285` | Innere Oberflächenbehandlungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `286` | Bauaustrocknung | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `287` | Baureinigung | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `288` | Gärtnerarbeiten (Gebäude) | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `291` | Architekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `292` | Bauingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `293` | Elektroingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `294` | HLK-Ingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `295` | Sanitäringenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `296` | Spezialisten | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `298` | Gebäudeautomationsingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `301` | Baugrubenaushub | `52` Ausführung |
| `311` | Baumeisterarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `312` | Montagebau Beton/Mauerwerk | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `313` | Montagebau in Stahl | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `314` | Montagebau in Holz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `315` | Montagebau Leichtkonstruktionen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `316` | Natur- und Kunststeinarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `317` | Schutzraumabschlüsse | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `321` | Fenster, Aussentüren, Tore | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `322` | Spenglerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `323` | Blitzschutz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `324` | Bedachungsarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `325` | Spezielle Dichtungen und Dämmungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `326` | Fassadenputze | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `327` | Äussere Oberflächenbehandlungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `328` | Äussere Abschlüsse, Sonnenschutz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `331` | Apparate Starkstrom | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `332` | Starkstrominstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `333` | Leuchten und Lampen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `334` | Energieverbraucher | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `335` | Apparate Schwachstrom | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `336` | Schwachstrominstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `337` | Gebäudeautomation | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `338` | Bauprovisorium | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `341` | Zulieferung Energieträger, Lagerung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `342` | Wärmeerzeugung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `343` | Wärmeverteilung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `344` | Lüftungsanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `345` | Klimaanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `346` | Kälteanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `347` | Spezialanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `348` | Dämmungen HLK-Installationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `351` | Allgemeine Sanitärapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `352` | Spezielle Sanitärapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `353` | Sanitäre Ver-/Entsorgungsapparate | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `354` | Sanitärleitungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `355` | Dämmungen Sanitärinstallationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `356` | Sanitärinstallationselemente | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `357` | Elektro- und Pneumatiktafeln | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `358` | Kücheneinrichtungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `361` | Aufzüge | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `362` | Fahrtreppen, Fahrsteige | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `364` | Sonstige Förderanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `365` | Hebeeinrichtungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `366` | Parkieranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `368` | Sonstige Lageranlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `371` | Gipserarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `372` | Metallbauarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `373` | Schreinerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `374` | Spezialverglasungen (innere) | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `375` | Schliessanlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `376` | Innere Abschlüsse | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `377` | Elementwände | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `381` | Bodenbeläge | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `382` | Wandbeläge, Wandbekleidungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `383` | Deckenbekleidungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `384` | Hafnerarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `385` | Innere Oberflächenbehandlungen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `386` | Bauaustrocknung | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `387` | Baureinigung | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `388` | Gärtnerarbeiten (Betriebseinrichtungen) | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `391` | Architekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `392` | Bauingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `393` | Elektroingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `394` | HLK-Ingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `395` | Sanitäringenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `396` | Spezialisten | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `398` | Gebäudeautomationsingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `401` | Erdbewegungen | `52` Ausführung |
| `411` | Baumeisterarbeiten | `52` Ausführung |
| `413` | Übriger Rohbau 1 | `52` Ausführung |
| `414` | Rohbau 2 | `52` Ausführung |
| `415` | Ausbau 1 | `52` Ausführung |
| `416` | Ausbau 2 | `52` Ausführung |
| `421` | Gärtnerarbeiten | `51` Ausführungsprojekt<br>`52` Ausführung |
| `422` | Einfriedungen | `51` Ausführungsprojekt<br>`52` Ausführung |
| `423` | Ausstattungen, Geräte | `51` Ausführungsprojekt<br>`52` Ausführung |
| `424` | Spiel- und Sportplätze | `51` Ausführungsprojekt<br>`52` Ausführung |
| `443` | Elektroanlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `444` | HLK-Kälteanlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `445` | Sanitäranlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `446` | Transportanlagen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `451` | Erdarbeiten | `52` Ausführung |
| `452` | Kanalisationsleitungen | `52` Ausführung |
| `453` | Elektroleitungen | `52` Ausführung |
| `454` | HLK-Kälteleitungen | `52` Ausführung |
| `455` | Sanitärleitungen | `52` Ausführung |
| `456` | Nebenarbeiten | `52` Ausführung |
| `461` | Erd- und Unterbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `462` | Kleine Kunstbauten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `463` | Oberbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `464` | Entwässerung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `465` | Werkleitungen und Kanalisationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `468` | Ausbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `471` | Baugrube | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `472` | Tragkonstruktion | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `473` | Oberbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `474` | Entwässerung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `475` | Werkleitungen und Kanalisationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `477` | Transportanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `478` | Ausbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `481` | Vortrieb | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `482` | Auskleidung, Gewölbe | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `483` | Oberbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `484` | Entwässerung und Wasserversorgung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `485` | Werkleitungen und Kanalisationen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `487` | Transportanlagen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `488` | Ausbau | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `491` | Architekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `492` | Bauingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `493` | Elektroingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `494` | HLK-Ingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `495` | Sanitäringenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `496` | Spezialisten | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `498` | Gebäudeautomationsingenieur | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `501` | Architekturwettbewerbe | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `502` | Ingenieurwettbewerbe | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `503` | Wettbewerbe Umgebungsgestaltung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `504` | Wettbewerbe künstlerische Gestaltung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `505` | Städtebaulicher Wettbewerb | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `506` | Innenarchitekturwettbewerb | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`22` Auswahlverfahren |
| `511` | Bewilligungen, Baugespann | `33` Bewilligungsverfahren, Auflageprojekt |
| `512` | Anschlussgebühren | `33` Bewilligungsverfahren, Auflageprojekt |
| `521` | Muster, Materialprüfungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `522` | Modelle | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `523` | Fotos | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `524` | Vervielfältigungen, Plankopien | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `525` | Dokumentation | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag |
| `531` | Bauzeitversicherungen | `52` Ausführung |
| `532` | Spezialversicherungen | `52` Ausführung |
| `533` | Selbstbehalt Schadenfälle | `52` Ausführung |
| `541` | Errichten von Hypotheken | `52` Ausführung |
| `542` | Baukreditzinsen, Bankspesen | `52` Ausführung |
| `543` | Baurechtszinsen | `52` Ausführung |
| `545` | Eigenkapitalzinsen | `52` Ausführung |
| `546` | Liegenschaftensteuer Bauzeit | `52` Ausführung |
| `548` | Rückvergütungen | `52` Ausführung |
| `557` | Betriebsplanung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss<br>`61` Betrieb |
| `558` | Projektleitung, Projektbegleitung | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss<br>`61` Betrieb |
| `561` | Bewachung durch Dritte | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `562` | Nachbar-/Mieterentschädigungen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `563` | Miete von fremdem Grund | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `564` | Gutachten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `565` | Reisespesen | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `566` | Grundsteinlegung, Aufrichte, Einweihung | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `567` | Anwaltskosten, Gerichtskosten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `568` | Baureklame | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`52` Ausführung |
| `591` | Architekt | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `592` | Bauingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `593` | Elektroingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `594` | HLK-Ingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `595` | Sanitäringenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `596` | Spezialisten | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `598` | Gebäudeautomationsingenieur | `11` Bedürfnisformulierung, Lösungsstrategien<br>`21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `901` | Garderobeneinrichtungen etc. | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `902` | Sporteinrichtungen | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `908` | Schutzraumausstattungen | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `921` | Vorhänge und Innendekorationsarbeiten | `52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `991` | Architekt | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `993` | Elektroingenieur | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `996` | Spezialisten | `31` Vorprojekt<br>`32` Bauprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `211.1` | Gerüste | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.0` | Unterlagsböden | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.1` | Fugenlose Bodenbeläge | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.2` | Bodenbeläge Kunststoffe/Textilien | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.4` | Bodenbeläge Naturstein | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.5` | Bodenbeläge Kunststein | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.6` | Bodenbeläge Plattenarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.7` | Bodenbeläge in Holz | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `281.8` | Doppelböden | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.0` | Fugenlose Wandbeläge | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.1` | Tapezierarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.2` | Wandverkleidungen Naturstein | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.3` | Wandverkleidungen Kunststein | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.4` | Wandbeläge Plattenarbeiten | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.5` | Wandverkleidung Holz/Holzwerkstoffe | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `282.6` | Wandverkleidung Kunststoffe/Textilien | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.1` | Deckenverkleidungen Metall | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.2` | Deckenverkleidungen Gips | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.3` | Deckenverkleidungen Mineralfasern | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.4` | Deckenverkleidungen Holz/Holzwerkstoffe | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.5` | Deckenverkleidungen Kunststoffe/Textilien | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.6` | Deckenverkleidungen Metall Paneele/Lamellen | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `283.7` | Deckenverkleidungen Metall Raster | `41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung |
| `296.0` | Geometer | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `296.2` | Innenarchitekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `296.3` | Bauphysiker | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `296.4` | Akustiker | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |
| `296.5` | Landschaftsarchitekt | `21` Projektdefinition, Machbarkeitsstudie<br>`31` Vorprojekt<br>`32` Bauprojekt<br>`33` Bewilligungsverfahren, Auflageprojekt<br>`41` Ausschreibung, Offertvergleich, Vergabeantrag<br>`51` Ausführungsprojekt<br>`52` Ausführung<br>`53` Inbetriebnahme, Abschluss |