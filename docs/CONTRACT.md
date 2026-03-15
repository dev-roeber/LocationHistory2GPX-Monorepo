# Consumer Contract

## Quelle

- Producer-Repo: `dev-roeber/LocationHistory2GPX`
- Producer-Commit: `7630b0e`

## Uebernommene Artefakte

- `Fixtures/contract/app_export.schema.json`
- `Fixtures/contract/CONTRACT_SOURCE.json`
- `Fixtures/contract/golden_app_export_contract_gate.json`
- `Fixtures/contract/golden_app_export_sample_small.json`
- `Fixtures/contract/golden_app_export_sample_medium.json`
- `Fixtures/contract/golden_app_export_sample_placeholder_*.json`

## Consumer-Verantwortung

- Schema-konformes App-Export-JSON dekodieren
- additive non-breaking Felder tolerieren, wenn sie optional bleiben
- bei unbekannter `schema_version` defensiv fehlschlagen

## Nicht Teil des Contracts

- `trips_index.json`
- Python-CLI/TUI/Shell-Flows
- Producer-interne Model- oder Exportpfade

## Update-Policy

1. Contract-Aenderung startet immer im Producer-Repo.
2. Dort werden Schema, Goldens und Contract-Tests aktualisiert.
3. Danach werden nur die relevanten Contract-Artefakte in dieses Repo uebernommen.
4. Anschliessend werden Decoder und Tests hier angepasst.

## Breaking vs Non-breaking

- Breaking: Feld entfernt, umbenannt, verschoben oder bestehende Semantik inkompatibel veraendert.
- Non-breaking: neue optionale Felder oder additive Strukturen.
- Breaking Changes erfordern dokumentierte Versionsaenderung und aktualisierte Goldens.
