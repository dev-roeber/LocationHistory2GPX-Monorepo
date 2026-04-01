# Privacy Manifest Scope

Stand: 2026-04-01 | Monorepo-Audit auf Linux-Host

---

## 1. Datenpunkte: lokal / optional-Upload / automatisch / nutzergesteuert

| Funktion / Datum | lokal | optional-Upload | automatisch | nutzergesteuert |
|---|---|---|---|---|
| Importierte History lesen (app_export.json, ZIP, Google Timeline) | ✅ lokal | — | nein | ✅ ja (manueller Import) |
| Importierte History speichern (Security-Scoped Bookmark) | ✅ lokal (UserDefaults) | — | nach Import | ✅ ja (Clear löscht Bookmark) |
| Live-Standort anzeigen (Karte, aktueller Marker) | ✅ lokal | — | nur bei aktivem Recording | ✅ ja (Nutzer startet Recording) |
| Live-Track aufzeichnen (foreground) | ✅ lokal | — | nein | ✅ ja |
| Background-Recording | ✅ lokal | — | nach `Always Allow`-Permission | ✅ ja (explizite Option + Permission) |
| Saved Live Tracks persistieren | ✅ lokal (App Support Storage) | — | beim Stoppen der Aufnahme | ✅ ja |
| App-Preferences (Einheiten, Tab, Kartenstil, Sprache etc.) | ✅ lokal (UserDefaults) | — | bei Änderung | ✅ ja |
| Bearer-Token für Server-Upload | ✅ lokal (Keychain) | — | nein | ✅ ja |
| **Server-Upload akzeptierter Live-Punkte** | — | ✅ optional (HTTPS POST) | nein | ✅ ja (explizite Aktivierung + URL) |
| Export GPX / KML / GeoJSON | ✅ lokal (system fileExporter) | — | nein | ✅ ja |
| Analytics / Telemetrie / Ad-Tracking | ❌ nicht vorhanden | — | — | — |

### Payload des Server-Uploads (wenn aktiviert)

```json
{
  "source": "LocationHistory2GPX-iOS",
  "sessionID": "<UUID>",
  "captureMode": "foregroundWhileInUse | backgroundAlways",
  "sentAt": "<ISO8601>",
  "points": [
    {
      "latitude": 52.123,
      "longitude": 13.456,
      "timestamp": "<ISO8601>",
      "horizontalAccuracyM": 12.5
    }
  ]
}
```

Kein Name, kein Gerätename, keine Apple-ID, keine Unique-Device-ID im Payload.
Kein Upload von importierter History, Exports, Einstellungen oder anderen App-Daten.

---

## 2. Technischer Privacy-Stand (belastbare Aussagen, nicht juristisch)

### Info.plist (wrapper/Config/Info.plist)

| Key | Wert | Bewertung |
|---|---|---|
| `NSLocationWhenInUseUsageDescription` | „Your location is used only inside LH2GPX to show your position on the map and to record live tracks you start manually." | ✅ vorhanden, App-Store-tauglich |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | „Your location is used only inside LH2GPX to continue a live track you started manually, even when the app is no longer in the foreground." | ✅ vorhanden, App-Store-tauglich |
| `UIBackgroundModes` | `location` | ✅ korrekt für Background-Recording |
| `NSUserTrackingUsageDescription` | nicht vorhanden | ✅ korrekt, kein ATT/Ad-Tracking |
| `NSCalendarsUsageDescription` etc. | nicht vorhanden | ✅ korrekt, kein Kalender-/Kontakte-/Kamera-Zugriff |

### PrivacyInfo.xcprivacy (wrapper/LH2GPXWrapper/PrivacyInfo.xcprivacy)

| Key | Wert | Bewertung |
|---|---|---|
| `NSPrivacyTracking` | `false` | ✅ korrekt, kein Cross-App-Tracking |
| `NSPrivacyTrackingDomains` | leer | ✅ korrekt |
| `NSPrivacyCollectedDataTypes` | leer | ⚠️ offene Frage (siehe Abschnitt 3) |
| `NSPrivacyAccessedAPITypes` | UserDefaults CA92.1 | ✅ korrekt für Preferences-Speicherung |

### Upload-Sicherheit (Code-verifiziert)

- HTTPS für nicht-localhost erzwungen (`endpointURL`-Getter in `LiveLocationServerUploadConfiguration`)
- HTTP-Endpunkte für nicht-localhost-Adressen werden im Code explizit abgelehnt
- Bearer-Token im Keychain, nicht in UserDefaults
- Kein hart kodierter Testendpunkt: `defaultTestEndpointURLString = ""`
- Upload standardmäßig deaktiviert: `isEnabled: false` als Default
- Queue-Limit: 10.000 Punkte (älteste werden verworfen bei Overflow)

---

## 3. Offene Apple-/Store-Review-Fragen

### 3a. NSPrivacyCollectedDataTypes für optionalen Server-Upload

**Frage:** Muss `NSPrivacyCollectedDataTypes` in PrivacyInfo.xcprivacy Standortdaten deklarieren, obwohl der Upload optional, nutzergesteuert und standardmäßig deaktiviert ist?

**Technischer Stand:**
- Wenn Nutzer Upload aktiviert und URL konfiguriert, werden Lat/Lon/Timestamp/Accuracy an den Nutzer-eigenen Server gesendet
- Apple definiert `NSPrivacyCollectedDataTypePreciseLocation` als deklarierbaren Typ
- Ob eine optionale, nutzerinitiierte Funktion deklarationspflichtig ist, hängt von Apples konkreter Policy-Auslegung ab
- **Kann nur auf Apple-Hardware im Store-Review-Kontext final beantwortet werden**

**Mögliche Lösung (falls Apple verlangt):**
```xml
<key>NSPrivacyCollectedDataTypes</key>
<array>
  <dict>
    <key>NSPrivacyCollectedDataType</key>
    <string>NSPrivacyCollectedDataTypePreciseLocation</string>
    <key>NSPrivacyCollectedDataTypeLinked</key>
    <false/>
    <key>NSPrivacyCollectedDataTypeTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypePurposes</key>
    <array>
      <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
    </array>
  </dict>
</array>
```
<!-- TODO: Vor App-Store-Einreichung mit Apple-Review-Ergebnis abgleichen -->

### 3b. ZIPFoundation-Abhängigkeit

**Frage:** Bringt ZIPFoundation eigene Privacy-Manifest-Anforderungen mit (z.B. `NSPrivacyAccessedAPICategoryFileTimestamp`)?

**Stand:**
- ZIPFoundation 0.9.20 ist pinned in Package.resolved
- Viele ZIP-Bibliotheken lesen/schreiben Datei-Timestamps
- Ob ZIPFoundation ein eigenes Privacy Manifest mitbringt, ist auf diesem Linux-Host nicht verifizierbar
- **Prüfung auf Apple-Host:** `xcodebuild` generiert Warnings bei fehlenden Manifest-Deklarationen für bekannte SDK APIs

### 3c. Datenschutzrichtlinien-URL (Pflicht)

- App Store Connect verlangt eine Datenschutzrichtlinien-URL
- Diese ist im Monorepo noch nicht eingetragen
- **Erforderlich vor jeder Einreichung**

### 3d. Support-URL

- App Store Connect Pflichtfeld
- Noch nicht konfiguriert

---

## 4. Nächste Schritte für Privacy Manifest auf Apple-Host

Auf einem Mac mit Xcode auszuführen, in dieser Reihenfolge:

1. **`xcodebuild archive`** für den aktuellen Stand ausführen:
   ```bash
   cd ~/repos/LocationHistory2GPX-Monorepo
   xcodebuild archive \
     -project wrapper/LH2GPXWrapper.xcodeproj \
     -scheme LH2GPXWrapper \
     -destination 'generic/platform=iOS' \
     -archivePath ~/Desktop/LH2GPXWrapper.xcarchive
   ```
   Xcode zeigt Warnings wenn API-Zugriffe nicht im Manifest deklariert sind.

2. **ZIPFoundation-Manifest prüfen:**
   Im generierten `.xcarchive` unter `Products/Applications/LH2GPX.app/Frameworks/` (falls als Framework eingebettet) oder direkt in der ZIPFoundation-Package-Quelle nach `PrivacyInfo.xcprivacy` suchen.

3. **NSPrivacyCollectedDataTypes Entscheidung:**
   - Optionalen Upload-Flow in der App aktivieren
   - App Store Connect → App Privacy → „Data Types" — App Review prüfen ob Standortdaten-Deklaration angefragt wird
   - Alternativ: Apple Developer Forum / TSI (Technical Support Incident) für Policy-Klarstellung

4. **Privacy Nutrition Label in App Store Connect:**
   Basierend auf Ergebnis aus Punkt 3: Data Types für „Precise Location" ggf. mit „Optional, user-initiated, app functionality" deklarieren.

5. **PrivacyInfo.xcprivacy aktualisieren:**
   Falls Schritt 3 ergibt, dass Deklaration erforderlich: `NSPrivacyCollectedDataTypes` ergänzen (Template oben).

---

## 5. Stand-Zusammenfassung

| Aspekt | Status | Verifikationsort |
|---|---|---|
| Kein Cross-App-Tracking | ✅ belastbar | PrivacyInfo.xcprivacy + Code |
| Location-Usage-Keys vorhanden | ✅ belastbar | Info.plist |
| Upload standardmäßig deaktiviert | ✅ belastbar | Code (LiveLocationServerUploadConfiguration) |
| Upload HTTPS-only | ✅ belastbar | Code (endpointURL-Getter) |
| Bearer-Token im Keychain | ✅ belastbar | Code (AppPreferences, KeychainHelper) |
| Kein Hardcode-Endpunkt | ✅ belastbar | Code (defaultTestEndpointURLString = "") |
| NSPrivacyCollectedDataTypes vollständig | ⚠️ offen | benötigt Apple-Host / Store-Review |
| ZIPFoundation-Manifest-Compliance | ⚠️ offen | benötigt Apple-Host / xcodebuild |
| Datenschutzrichtlinien-URL | ❌ fehlt | App Store Connect |
| Support-URL | ❌ fehlt | App Store Connect |
| Fresh xcodebuild archive verifiziert | ⚠️ historisch (2026-03-17) | Apple-Host |
| End-to-End Upload auf Gerät | ❌ offen | Apple-Host + echter Endpunkt |
