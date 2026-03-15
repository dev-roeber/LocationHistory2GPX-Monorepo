# Codex Agent – Projektprofil: LocationHistory2GPX-iOS

## Projektrolle

- Dieses Repo ist ausschliesslich Consumer des stabilen App-Exports aus `LocationHistory2GPX`.
- Keine Producer-Verantwortung hierher ziehen.
- Keine Google-Rohdaten parsern.
- Keine Produkt-UI in diesem Bootstrap-Schritt bauen.

## Stabiler Contract

- Formale Quelle: `Fixtures/contract/app_export.schema.json`
- Decoder-Referenzen: `Fixtures/contract/golden_app_export_*.json`
- Update-Herkunft: Producer-Repo `dev-roeber/LocationHistory2GPX` ab Commit `7630b0e`
- `trips_index.json` gehoert nicht zum Consumer-Contract

## Arbeitsstil

- Foundation-first, keine unnötigen Frameworks
- Decoder und Modelle klein, klar, testbar halten
- additive Felder optional modellieren
- Breaking Changes nur mit dokumentierter Contract-Version

## Pflichtchecks

- `swift test`

Wenn `swift` lokal fehlt, das im Abschluss explizit sagen und nicht als grün behaupten.
