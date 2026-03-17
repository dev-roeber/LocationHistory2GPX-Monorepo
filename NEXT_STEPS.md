# NEXT_STEPS

Abgeleitet aus der Roadmap. Nur die konkret naechsten offenen Schritte.

1. **Lokale Produktweiterentwicklung (aktiver Fokus)** – Naechster Schritt: Phase 19.3 bestimmen. Kandidaten: GPX-Export aus Day-Detail, Datumsbereichs-Filter in der Day-Liste, weitere UX-Feinschliffe auf Basis realem iPhone-Betrieb.
2. **Phase 20 / Phase 21 – bewusst geparkt** – Erfordert Apple Developer Account / ASC-Zugang. Kein aktiver Fokus. Wird aufgenommen, sobald Zugang tatsaechlich verfuegbar ist.
3. Contract-Files weiter ausschliesslich vom Producer-Repo aus aktualisieren.

**Abgeschlossene Phase 19.2 (2026-03-18):**
- Clear-Button-Bedingungen auf message.kind == .error eingegrenzt
- Ghost-Button nach clearContent() beseitigt (kein sichtbarer Loop mehr)
- Toolbar und Empty-State in AppShellRootView.swift und ContentView.swift behoben

**Abgeschlossene Phase 19.1 (2026-03-18):**
- Tool-Name im Empty-State und Idle-Statustext kommuniziert
- Zeitangaben in Day-Detail auf lesbare Uhrzeit formatiert (ISO 8601 → lokale Uhrzeit)
- Typ-Labels formatiert (WALKING → Walking, HOME → Home)

**Lokaler iPhone-Betrieb: vollstaendig verifiziert (2026-03-17)** – iPhone 15 Pro Max und iPhone 12 Pro Max. iPad bewusst spaeter.
