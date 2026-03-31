# AUDIT_HARDMODE_WRAPPER_2026-03-31_04-59

## 1. Ziel / Scope

- Deep Audit des Wrapper-Repos `LH2GPXWrapper`
- Abgleich von Wrapper-Doku, Xcode-Konfiguration, Privacy-/Runbook-Wording und Cross-Repo-Truth
- repo-wahre Korrektur der betroffenen Wrapper-Dokumentation

## 2. Gelesene Pflichtdateien

- `CHANGELOG.md`
- `README.md`
- `NEXT_STEPS.md`
- `ROADMAP.md`
- `docs/LOCAL_IPHONE_RUNBOOK.md`
- `docs/TESTFLIGHT_RUNBOOK.md`

## 3. Zusätzlich entdeckte relevante Dateien

- `LH2GPXWrapper.xcodeproj/project.pbxproj`
- `LH2GPXWrapper.xctestplan`
- `Config/Info.plist`
- `LH2GPXWrapper/PrivacyInfo.xcprivacy`
- `LH2GPXWrapper/ContentView.swift`
- `LH2GPXWrapper/LH2GPXWrapperApp.swift`
- `LH2GPXWrapperTests/LH2GPXWrapperTests.swift`
- `LH2GPXWrapperUITests/LH2GPXWrapperUITests.swift`
- `LH2GPXWrapperUITests/LH2GPXWrapperUITestsLaunchTests.swift`
- `AUDIT_HARDMODE_WRAPPER_2026-03-30_10-35.md`
- `AUDIT_MASTER_2026-03-30_11-01.md`

## 4. Ausgeführte Prüfungen / Tests / Befehle

- `git fetch --all --prune`
  - Ergebnis: `origin/main` aktuell, neuer Audit-Branch angelegt
- `git checkout main && git pull --ff-only origin main && git checkout -b chore/preflight-deep-audit-2026-03-31_04-59`
  - Ergebnis: Branch sauber vom aktuellen `main` erzeugt
- `git status --short --branch`
  - Ergebnis: sauberer Arbeitsstand vor Änderungen
- `git log --oneline -n 5`
  - Ergebnis: aktuelle Spitze `a9152ad`, `446b0b7`, `80272ba`, `296d44c`, `b181616`
- `git diff --check`
  - Ergebnis: sauber
- `command -v xcodebuild`
  - Ergebnis: kein Treffer auf diesem Host

## 5. Gefundene Widersprüche

- Wrapper-Doku nannte im aktuellen Truth-Block noch `217` Core-Tests statt des frischen Core-Standes `228 / 2 / 0`
- Wrapper-NEXT_STEPS priorisierte Heatmap und Apple-CLI, aber noch nicht den aktuellen offenen Block `Live / Upload / Insights / Days`
- Wrapper-ROADMAP-Kopfblock beschrieb den Server-Upload noch zu schmal und ohne die spaeteren Queue-/Failure-/Flush-Zustaende
- `docs/TESTFLIGHT_RUNBOOK.md` nutzte noch das zu starke Wort `konform` fuer `PrivacyInfo.xcprivacy`
- `docs/LOCAL_IPHONE_RUNBOOK.md` sprach stellenweise wie ein aktueller Host-Befund, obwohl in diesem Audit kein neuer Apple- oder Simulator-Lauf moeglich war

## 6. Gefundene veraltete Aussagen

- `217` als aktueller Core-Linux-Truth
- `konform` fuer das Privacy-Manifest
- zu praesentische Formulierungen fuer den historischen Device-Teilbefund vom 2026-03-30

## 7. Gefundene fehlende Doku

- expliziter Linux-Host-Hinweis `xcodebuild auf diesem Audit-Host nicht vorhanden`
- harmonisierte offene Punkte fuer `Live`, `Upload`, `Insights`, `Days`
- aktualisierte Wrapper-ROADMAP fuer den erweiterten `Live`-/Upload-/Insights-Scope

## 8. Konkrete Korrekturen

- `CHANGELOG.md` um Audit-/Doc-Sync-Eintrag ergaenzt
- `README.md` auf `228 / 2 / 0` und historischen Apple-Stand korrigiert
- `NEXT_STEPS.md` an den offenen Core-Truth angepasst
- `ROADMAP.md`-Kopfblock fuer erweiterten `Live`-/Upload-/Insights-/Days-Scope und aktuellen Linux-Truth ergaenzt
- `docs/LOCAL_IPHONE_RUNBOOK.md` mit explizitem Host-Hinweis und historischer Kennzeichnung versehen
- `docs/TESTFLIGHT_RUNBOOK.md` bei Privacy-/Review-Wording entschaerft

## 9. Verbleibende offene Punkte

- kein frischer Wrapper-`xcodebuild`-Gegenlauf fuer den aktuellen Stand
- keine neue Device-Verifikation fuer Heatmap, Live-Tab, Upload-Zustaende, Background-Recording und Auto-Restore
- keine finale Apple-Review-/Privacy-Einordnung fuer den optionalen Upload-Pfad

## 10. Ehrliche Grenzen der Verifikation

- auf diesem Audit-Host fehlt `xcodebuild`
- Wrapper-Build-/Test-/Device-Aussagen bleiben deshalb historische Nachweise aus frueheren Apple-Hosts
- `git diff --check` verifiziert nur die formale Arbeitsbaum-Sauberkeit, nicht den Apple-Build

## 11. Abschlussfazit

- Die Wrapper-Doku ist wieder mit dem aktuellen Core-Truth synchronisiert.
- Frisch belegt ist auf diesem Host nur der Linux-Truth des eingebundenen Core-Repos und die saubere Wrapper-Arbeitsbaum-Lage.
- Alle darueber hinausgehenden Apple-/Device-/Review-Themen bleiben explizit offen.
