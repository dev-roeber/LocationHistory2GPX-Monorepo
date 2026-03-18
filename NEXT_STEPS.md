# NEXT_STEPS

Abgeleitet aus der Roadmap. Nur die konkret naechsten offenen Schritte.

1. **Live-Recording-Folgearbeiten (Phase 20.3+)** – MVP fertig. Naechste saubere Ausbaustufen:
   - Background-Location technisch vorbereiten und getrennt aktivierbar machen
   - Draft-/Resume-Modell fuer laufende Tracks sauber separat aufbauen
   - Recorded-Track-History als eigene Ansicht und spaeter Export der aufgezeichneten Tracks
   - manuelle Verwaltung aufgezeichneter Tracks (loeschen / umbenennen) ohne Vermischung mit Importdaten
2. **Export-Erweiterungen (Phase 20.x)** – MVP fertig. Moegliche Folgeschritte:
   - per-Track-Selektion (einzelne Routes innerhalb eines Tages auswaehlen)
   - Visits/Activities als GPX-Waypoints exportieren
   - Weitere Formate: KML, CSV (ExportFormat Enum bereits vorbereitet)
   - Exportierter Dateiname anpassbar machen
3. **Phase 21 – App Store / TestFlight – bewusst geparkt** – Erfordert Apple Developer Account / ASC-Zugang.
4. **Accessibility-Audit – bewusst geparkt** – Kein konkreter Bug, kein Trigger.
5. Contract-Files weiter ausschliesslich vom Producer-Repo aus aktualisieren.

**Abgeschlossene Phase 20.1 (2026-03-18):**
- GPXBuilder: Path.points → GPX 1.1 Tracks, XML-Escaping, Dateinamen-Helfer
- ExportSelectionState: value-type Set<String>, in AppSessionState eingebettet (app-weit)
- GPXDocument: FileDocument fuer fileExporter-Flow
- AppExportView: 4. Tab (iPhone) + Sheet (iPad), Checkboxen, Select All, Export-Button
- ExportFormat Enum: GPX aktiv, KML/CSV-Architektur vorbereitet
- AppDayRow: Export-Badge wenn Tag selektiert
- 16 neue Tests; 112/112 gruen

**Abgeschlossene Phase 20.2 (2026-03-18):**
- LiveLocationFeatureModel + SystemLiveLocationClient fuer foreground-only While-In-Use-Tracking
- LiveTrackRecorder mit Accuracy-/Dedupe-/Mindestdistanz-/Flood-Logik
- AppLiveLocationSection im Day-Detail: Toggle, Permission-State, aktueller Standort, Live-Polyline
- RecordedTrackFileStore: getrennte Persistenz abgeschlossener Live-Tracks, save on stop, kein Auto-Resume
- Wrapper-Info.plist: NSLocationWhenInUseUsageDescription
- 13 neue Tests; 125/125 gruen

**Abgeschlossene Phasen 19.23–19.27 (2026-03-18):**
- 19.27: DemoSupport-Typealiases entfernt, Public-API-Docs, Dead Code entfernt
- 19.26: God-File Split (AppContentSplitView 1677->444 Zeilen, 6 neue Dateien)
- 19.25: "Paths"->"Routes", Daily Averages Guard, Activity-Breakdown-Farben
- 19.24: Accessibility (VoiceOver, coloredCard, iOS-16 Fallback, Empty States)
- 19.23: CI/CD, SwiftLint, ZIPFoundation-Pin, onChange-Fix, Wrapper-Tests
