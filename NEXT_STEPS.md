# NEXT_STEPS

Abgeleitet aus der Roadmap. Nur die konkret naechsten offenen Schritte.

1. **Phase 19.32 – Insights Empty / No-Data Hardening**
   - Insights fuer no-days- und low-data-Faelle mit echten Empty States ausstatten
   - blanke Flaechen vermeiden, wenn zwar `ExportInsights` existiert, aber keine sinnvolle Darstellung moeglich ist
2. **Phase 19.33 – Overview-Informationsarchitektur / Primaeraktionen**
   - Overview wieder klarer auf importierte History, Status und Hauptnavigation ausrichten
   - sekundaere Track-Utilities optisch und inhaltlich hinter die Kerninformation ruecken
   - Actions-Menue, Labels und Status-Texte in ihrer Sichtbarkeit kritisch nachschaerfen
3. **Phase 19.34 – Days List / Export-Koharenz**
   - Export-Selektion in der Day-Liste visuell klarer priorisieren
   - Such- und Leerzustaende nicht nur korrekt, sondern auch klar priorisiert darstellen
4. **Phase 19.35 – Day-Detail-Hierarchie**
   - Live Recording und Track-Bearbeitung sauberer von importierten Tagesdaten trennen
   - Day-Detail-Screen in eine klarere primare/sekundaere Reihenfolge bringen
5. **Phase 19.36 – Track-Library / Track-Editor-Zugang**
   - Benennung, Iconographie und Zugang fuer gespeicherte Live-Tracks klarer machen
   - die Trennung zu importierter History weiter schaerfen, ohne neue Scope-Bloecke aufzumachen
6. **Phase 19.37 – Visualisierung / Charts-Politur**
   - Low-Data-Verhalten, Achsen, Legenden und Tap-Affordances der vorhandenen Charts verbessern
   - keine neuen Analyse-Daten erfinden, sondern die vorhandenen konsistenter darstellen
7. **Phase 19.38 – Export-UX-Politur**
   - Disabled- und Fehlerzustaende des Export-Flows erklaerender machen
   - Dateinamenerwartung und Formatklarheit schaerfen, ohne neue Exportformate freizuschalten
8. **Phase 20 / 21 – bewusst nicht jetzt**
   - keine weiteren `20.x`-Folgearbeiten fuer Background-Location, Resume oder Recorded-Track-Export aktivieren
   - keine Apple-/ASC-/TestFlight-/Release-Arbeit
9. Contract-Files weiter ausschliesslich vom Producer-Repo aus aktualisieren.

**Abgeschlossene Phase 19.31 (2026-03-19):**
- `DaySummary.hasContent` ergaenzt und Query-Layer auf repo-wahre no-content-Tage gehaertet
- initiale Tagesauswahl bevorzugt jetzt contentful days statt blindem first-day-Verhalten
- compact/regular `Days` oeffnen no-content-Tage nicht mehr als normale Detailziele
- regular detail zeigt einen klaren Rueckweg zur `Overview`
- Export-Badge in gruppierter und ungruppierter Day-Liste jetzt konsistent
- 2 neue Session-State-Tests plus Query-Assertions; `swift test` wieder gruen

**Abgeschlossene Phase 19.30 (2026-03-18):**
- LiveLocationFeatureModel + SystemLiveLocationClient fuer foreground-only While-In-Use-Tracking
- LiveTrackRecorder mit Accuracy-/Dedupe-/Mindestdistanz-/Flood-Logik
- AppLiveLocationSection im Day-Detail: Toggle, Permission-State, aktueller Standort, Live-Polyline
- RecordedTrackFileStore: getrennte Persistenz abgeschlossener Live-Tracks, save on stop, kein Auto-Resume
- Wrapper-Info.plist: NSLocationWhenInUseUsageDescription
- 13 neue Tests; 125/125 gruen

**Abgeschlossene Phase 19.29 (2026-03-18):**
- GPXBuilder: Path.points → GPX 1.1 Tracks, XML-Escaping, Dateinamen-Helfer
- ExportSelectionState: value-type Set<String>, in AppSessionState eingebettet (app-weit)
- GPXDocument: FileDocument fuer fileExporter-Flow
- AppExportView: 4. Tab (iPhone) + Sheet (iPad), Checkboxen, Select All, Export-Button
- ExportFormat Enum: GPX aktiv, KML/CSV-Architektur vorbereitet
- AppDayRow: Export-Badge wenn Tag selektiert
- 16 neue Tests; 112/112 gruen

**Abgeschlossene Phase 19.28 (2026-03-19):**
- neue `AppPreferences`-Domain fuer echte lokale Optionen
- Optionen-Seite ueber Actions-Menue in Core-App und Wrapper erreichbar
- Distanz-Einheit, Start-Tab, Kartenstil und technische Importdetails app-weit steuerbar
- bewusst keine Cloud-/Server-/Sync-Toggles
- 4 neue Tests; 135/135 gruen

**Abgeschlossene Phasen 19.23–19.27 (2026-03-18):**
- 19.27: DemoSupport-Typealiases entfernt, Public-API-Docs, Dead Code entfernt
- 19.26: God-File Split (AppContentSplitView 1677->444 Zeilen, 6 neue Dateien)
- 19.25: "Paths"->"Routes", Daily Averages Guard, Activity-Breakdown-Farben
- 19.24: Accessibility (VoiceOver, coloredCard, iOS-16 Fallback, Empty States)
- 19.23: CI/CD, SwiftLint, ZIPFoundation-Pin, onChange-Fix, Wrapper-Tests
