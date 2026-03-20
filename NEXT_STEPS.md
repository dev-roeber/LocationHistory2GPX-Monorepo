# NEXT_STEPS

Abgeleitet aus der Roadmap. Nur die konkret naechsten offenen Schritte, repo-wahr und nach aktuellem Code-Stand priorisiert.

## 1. Phase 19.43 – Background-Recording auf echter Apple-Hardware haerten

Status: **teilweise umgesetzt**

Bereits drin:
- Background-Recording-Codepfad
- `Always Allow`-Upgrade im Live-Location-Modell
- Wrapper-Deklarationen fuer `NSLocationAlwaysAndWhenInUseUsageDescription` und `UIBackgroundModes=location`

Fehlt noch:
- echte Device-Verifikation fuer Permission-Upgrade, laufende Aufnahme im Hintergrund und Stop-/Persistenzverhalten
- separater dokumentierter Nachweis im Apple-/Wrapper-Runbook
- Korrektur verbleibender Produkttexte, falls der reale Device-Flow noch Unterschiede zeigt

## 2. Phase 19.44 – Live-Tracks-Oberflaeche final einordnen

Status: **teilweise umgesetzt**

Bereits drin:
- dedizierte `Saved Live Tracks`-Library
- Editor fuer gespeicherte Tracks
- Export-Unterstuetzung fuer Saved Live Tracks

Fehlt noch:
- Produktentscheidung, ob `Saved Live Tracks` nur ein lokaler Nebenfluss bleibt oder einen eigenen primaeren App-Bereich bekommt
- falls eigener Bereich gewuenscht: Einstieg, Navigation und Informationsarchitektur entsprechend anpassen

## 3. Phase 19.45 – Deduplizierung / Bereinigung

Status: **teilweise umgesetzt**

Bereits drin:
- Live-Recorder dedupliziert und filtert nach Genauigkeit / Mindestbewegung
- Export-Sanitizer entfernt doppelte aufeinanderfolgende Pfadpunkte

Fehlt noch:
- breitere Bereinigung fuer importierte History vor Export
- klarere Produktentscheidung, wie aggressiv History-Daten bereinigt werden duerfen

## 4. Phase 19.46 – Highlights / Insights / Zeitraumsauswahl

Status: **geplant**

Fehlt noch:
- mehr Highlights in Overview und Insights
- deutlich mehr Insight-Module
- waehlbarer angezeigter Zeitraum fuer Overview/Insights statt nur passiver Date-Range-Anzeige

## 5. Phase 19.47 – Sprache / Lokalisierung

Status: **teilweise umgesetzt**

Bereits drin:
- Sprachwahl `English` / `Deutsch` in den Optionen
- deutsche Abdeckung fuer Shell-, Optionen-, Import-Entry-, Live-Recording- und zentrale Exportflaechen
- englischer Fallback fuer noch nicht portierte Strings

Fehlt noch:
- breitere Lokalisierungsabdeckung der restlichen UI-Texte
- belastbare Lokalisierungsstrategie fuer Core + Wrapper
- frische Sichtpruefung auf Apple-Hardware, dass keine unportierten Kernflaechen uebersehen wurden

## 6. Phase 19.48 – Heatmap

Status: **geplant**

Fehlt noch:
- Produktentscheidung fuer Heatmap-Scope und Datenbasis
- UI-/Map-Integration ohne bestehende Route-/Waypoint-Vorschau zu verwaessern

## 7. Phase 19.49 – Weitere Exportformate nach GeoJSON

Status: **geplant**

Fehlt noch:
- Priorisierung zwischen `CSV` und `KMZ`
- saubere Einhaengung in den bestehenden Exportmodus statt eines unklaren Formatwachstums

## 8. Phase 20 – Apple / ASC / TestFlight / externe Distribution

Status: **bewusst geparkt**

- bleibt ausserhalb des aktuellen Linux-Hosts
- braucht Apple-Hardware, Signierungskontext und reale Distribution statt lokaler Repo-Arbeit

## 9. Phase 21 – spaetere Folgearbeit

Status: **bewusst unberuehrt**

- weitergehende Konkurrenz-/Feature-Recherche
- groessere Produktentscheidungen jenseits des aktuellen lokalen Ausbaupfads

Contract-Files werden weiterhin ausschliesslich vom Producer-Repo aus aktualisiert.
