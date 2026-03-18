# CHANGELOG

## 2026-03-18

### Import Truth Sync
- verbliebene Core-UI-Texte von `app_export`-Spezialfall auf den echten JSON-/ZIP-Import-Scope umgestellt
- ZIP-Fehlermeldungen auf aktuelle Unterstuetzung fuer LH2GPX- und Google-Timeline-Archive korrigiert
- `AGENTS.md`, README und Apple-/Xcode-Doku auf den realen Importstand synchronisiert

### Phase 20.2 – Live Recording MVP
- foreground-only Live-Location fuer die Kartenansicht eingebaut
- manuellen Ein/Aus-Schalter mit sauber modellierten Permission-Zustaenden hinzugefuegt
- Live-Track mit Accuracy-/Dedupe-/Mindestdistanz-Filtern und Polyline-Rendering umgesetzt
- abgeschlossene Live-Tracks getrennt von importierter History in einem dedizierten Store persistiert
- bewusst offen gelassen: Background-Tracking, Auto-Resume von Drafts, Export aufgezeichneter Live-Tracks
