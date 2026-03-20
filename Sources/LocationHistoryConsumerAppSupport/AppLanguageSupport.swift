import Foundation

public enum AppLanguagePreference: String, CaseIterable, Identifiable {
    case english
    case german

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        }
    }

    public var locale: Locale {
        switch self {
        case .english:
            return Locale(identifier: "en")
        case .german:
            return Locale(identifier: "de")
        }
    }

    public func localized(_ english: String) -> String {
        switch self {
        case .english:
            return english
        case .german:
            return AppGermanTranslations.values[english] ?? english
        }
    }
}

enum AppGermanTranslations {
    static let values: [String: String] = [
        "Overview": "Übersicht",
        "Days": "Tage",
        "Insights": "Einblicke",
        "Export": "Export",
        "Options": "Optionen",
        "Actions": "Aktionen",
        "Clear": "Leeren",
        "Done": "Fertig",
        "Saved Live Tracks": "Gespeicherte Live-Tracks",
        "Open Library": "Mediathek öffnen",
        "No Results": "Keine Treffer",
        "Primary Actions": "Wichtige Aktionen",
        "Browse Days": "Tage ansehen",
        "Open Insights": "Einblicke öffnen",
        "Export GPX": "GPX exportieren",
        "Highlights": "Highlights",
        "Busiest Day": "Aktivster Tag",
        "Longest Distance": "Längste Strecke",
        "Total Distance": "Gesamtstrecke",
        "Filtered Export": "Gefilterter Export",
        "No Insights Available": "Keine Einblicke verfügbar",
        "Load a location history file to see detailed insights.": "Lade eine Standortverlauf-Datei, um detaillierte Einblicke zu sehen.",
        "Select a day from the list to view details.": "Wähle einen Tag aus der Liste, um Details zu sehen.",
        "Back to Overview": "Zurück zur Übersicht",
        "Local Recording": "Lokale Aufzeichnung",
        "Current position and saved live tracks stay separate from imported history.": "Aktuelle Position und gespeicherte Live-Tracks bleiben von importierter Historie getrennt.",
        "Record": "Aufzeichnen",
        "Record live track": "Live-Track aufzeichnen",
        "Current Location": "Aktueller Standort",
        "Center on current location": "Auf aktuellen Standort zentrieren",
        "Live location is off": "Live-Standort ist aus",
        "Turn recording on to request foreground-only location access and draw a live track.": "Aktiviere die Aufzeichnung, um Standortzugriff im Vordergrund anzufordern und einen Live-Track zu zeichnen.",
        "Distance Units": "Entfernungseinheiten",
        "Start Tab": "Start-Tab",
        "Show Technical Import Details": "Technische Importdetails anzeigen",
        "Display": "Anzeige",
        "Controls how much metadata the app shows around imports and source information.": "Steuert, wie viele Metadaten die App rund um Importe und Quelleninformationen anzeigt.",
        "Default Map Style": "Standard-Kartenstil",
        "Maps": "Karten",
        "Applies to the day-detail map and live-location map.": "Gilt für die Tagesdetail-Karte und die Live-Standort-Karte.",
        "Accuracy Filter": "Genauigkeitsfilter",
        "Recording Detail": "Aufzeichnungsdetail",
        "Allow Background Recording": "Hintergrundaufzeichnung erlauben",
        "Accepted Accuracy": "Akzeptierte Genauigkeit",
        "Minimum Movement": "Mindestbewegung",
        "Minimum Time Gap": "Minimaler Zeitabstand",
        "Server Upload": "Server-Upload",
        "Language": "Sprache",
        "Upload to Custom Server": "An eigenen Server senden",
        "Server URL": "Server-URL",
        "Bearer Token (optional)": "Bearer-Token (optional)",
        "Language and Upload": "Sprache und Upload",
        "Choose the app language and optionally forward accepted live-recording points to your own endpoint. Upload stays off until a valid URL is present.": "Wähle die App-Sprache und leite akzeptierte Live-Aufzeichnungspunkte optional an deinen eigenen Endpunkt weiter. Der Upload bleibt aus, bis eine gültige URL vorhanden ist.",
        "Privacy": "Datenschutz",
        "Location Data": "Standortdaten",
        "Stored locally on this device": "Lokal auf diesem Gerät gespeichert",
        "Foreground + optional background": "Vordergrund + optional Hintergrund",
        "Foreground only": "Nur Vordergrund",
        "This app keeps imports and live tracks local by default. Server upload is optional, user-controlled and only sends accepted live-recording points to the configured endpoint.": "Diese App hält Importe und Live-Tracks standardmäßig lokal. Server-Upload ist optional, nutzergesteuert und sendet nur akzeptierte Live-Aufzeichnungspunkte an den konfigurierten Endpunkt.",
        "Technical": "Technisch",
        "Reset Options": "Optionen zurücksetzen",
        "Kilometers": "Kilometer",
        "Miles": "Meilen",
        "Standard": "Standard",
        "Satellite Hybrid": "Satellit Hybrid",
        "Relaxed": "Locker",
        "Balanced": "Ausgewogen",
        "Strict": "Strikt",
        "Battery Saver": "Batteriesparer",
        "Detailed": "Detailliert",
        "Waiting for Location Permission": "Warte auf Standortfreigabe",
        "Location Permission Not Requested": "Standortfreigabe nicht angefordert",
        "Location Access Restricted": "Standortzugriff eingeschränkt",
        "Location Access Denied": "Standortzugriff verweigert",
        "Recording in Background": "Aufzeichnung im Hintergrund",
        "Background Upgrade Pending": "Hintergrundfreigabe ausstehend",
        "Recording Live Track": "Live-Track wird aufgezeichnet",
        "Live Location Ready": "Live-Standort bereit",
        "Search by date": "Nach Datum suchen",
        "Search by date, weekday or month": "Nach Datum, Wochentag oder Monat suchen",
        "This app currently has no cloud sync and no server transfer. Background recording remains local to this device and still depends on Apple location permission.": "Diese App hat derzeit keine Cloud-Synchronisierung und keinen Servertransfer. Hintergrundaufzeichnung bleibt lokal auf diesem Gerät und hängt weiterhin von Apples Standortfreigabe ab.",
        "English": "Englisch",
        "Accepts up to 100 m accuracy.": "Akzeptiert bis zu 100 m Genauigkeit.",
        "Accepts up to 65 m accuracy.": "Akzeptiert bis zu 65 m Genauigkeit.",
        "Accepts up to 25 m accuracy.": "Akzeptiert bis zu 25 m Genauigkeit.",
        "Fewer stored points, larger movement threshold.": "Weniger gespeicherte Punkte, höherer Bewegungs-Schwellwert.",
        "Default spacing for local live tracks.": "Standardabstand für lokale Live-Tracks.",
        "Keeps more movement detail with tighter thresholds.": "Behält mehr Bewegungsdetails mit engeren Schwellwerten.",
        "App Language": "App-Sprache",
        "Test Endpoint": "Test-Endpunkt",
        "Accepted live-recording points only. Use an HTTP(S) endpoint you control. The default test endpoint is prefilled with this server IP and can be changed at any time.": "Nur akzeptierte Live-Aufzeichnungspunkte. Nutze einen HTTP(S)-Endpunkt unter deiner Kontrolle. Der Standard-Testendpunkt ist mit der IP dieses Servers vorbefüllt und kann jederzeit geändert werden.",
        "Enabled": "Aktiv",
        "Disabled": "Deaktiviert",
        "Enabled (invalid URL)": "Aktiv (ungültige URL)",
        "Upload status": "Upload-Status",
        "Import your location history": "Importiere deinen Standortverlauf",
        "Open an app_export.json or .zip from the LocationHistory2GPX tool — or a Google Timeline location-history.json or .zip from Google Takeout.": "Öffne eine app_export.json oder .zip aus dem LocationHistory2GPX-Tool oder eine Google-Timeline-location-history.json bzw. .zip aus Google Takeout.",
        "Open an LH2GPX app_export.json or .zip from the LocationHistory2GPX tool — or a Google Timeline location-history.json or .zip from Google Takeout.": "Öffne eine LH2GPX-app_export.json oder .zip aus dem LocationHistory2GPX-Tool oder eine Google-Timeline-location-history.json bzw. .zip aus Google Takeout.",
        "Open location history file": "Standortverlauf-Datei öffnen",
        "Load Demo Data": "Demodaten laden",
        "Open Another File": "Andere Datei öffnen",
        "Demo Data": "Demodaten",
        "Reload Demo": "Demo neu laden",
        "Opening location history...": "Standortverlauf wird geöffnet...",
        "Loading demo app export...": "Demo-App-Export wird geladen...",
        "Load Demo": "Demo laden",
        "Import JSON": "JSON importieren",
        "No demo source loaded": "Keine Demoquelle geladen",
        "Load the bundled demo fixture or import a local app_export.json file.": "Lade die gebündelte Demo-Datei oder importiere eine lokale app_export.json-Datei.",
        "Nothing to Export": "Nichts zu exportieren",
        "Import a location history file or save a live track first to enable export.": "Importiere zuerst eine Standortverlauf-Datei oder speichere einen Live-Track, um den Export zu aktivieren.",
        "Select All": "Alle auswählen",
        "Deselect All": "Auswahl aufheben",
        "Preview": "Vorschau",
        "Filter Imported History": "Importierte Historie filtern",
        "Mode": "Modus",
        "Format": "Format"
    ]
}
