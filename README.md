# LocationHistory2GPX-iOS

Minimales separates iOS-Consumer-Repo fuer den stabilen App-Export von `LocationHistory2GPX`.

## Rolle dieses Repos

- Consumer only
- kein Parser fuer Google-Rohdaten
- keine GPX-/GeoJSON-/CSV-Erzeugung
- keine Produkt-UI in diesem Schritt
- offline-first, ohne Netzwerkcode, Tracking oder Cloud-Sync

## Contract-Herkunft

- Producer-Repo: `dev-roeber/LocationHistory2GPX`
- Referenz-Commit: `7630b0e`
- Uebernommene Contract-Artefakte:
  - `Fixtures/contract/app_export.schema.json`
  - `Fixtures/contract/golden_app_export_*.json`
  - `Fixtures/contract/CONTRACT_SOURCE.json`
- Referenz fuer die Boundary im Producer-Repo: `docs/SEPARATE_IOS_REPO_BOUNDARY.md`

## Was dieses Repo aktuell kann

- App-Export-JSON laden
- gegen Swift-Modelle decodieren
- Golden-basierte Contract-Tests lokal ausfuehren
- klar dokumentieren, welche Producer-Artefakte konsumiert werden

## Was dieses Repo aktuell bewusst nicht kann

- Karten-/Listen-/SwiftUI-Produkt-UI
- Import von Google-Rohdateien
- Producer-Logik aus dem Python-Repo
- `trips_index.json` konsumieren

## Struktur

- `Sources/LocationHistoryConsumer/`
  - `AppExportModels.swift`
  - `AppExportDecoder.swift`
  - `ContractVersion.swift`
- `Tests/LocationHistoryConsumerTests/`
  - `AppExportGoldenDecodingTests.swift`
  - `ContractFixturePresenceTests.swift`
- `Fixtures/contract/`
  - `app_export.schema.json`
  - `golden_app_export_*.json`
- `docs/CONTRACT.md`
- `ROADMAP.md`
- `NEXT_STEPS.md`

## Lokale Nutzung

```bash
swift test
```

Wenn `swift` lokal nicht installiert ist, koennen die Dateien hier trotzdem vorbereitet und geprueft werden, aber der Build/Test-Lauf muss spaeter auf einer Swift-Umgebung nachgezogen werden.
