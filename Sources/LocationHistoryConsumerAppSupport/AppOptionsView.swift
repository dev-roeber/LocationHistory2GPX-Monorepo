#if canImport(SwiftUI)
import SwiftUI

public struct AppOptionsView: View {
    @ObservedObject private var preferences: AppPreferences

    public init(preferences: AppPreferences) {
        self._preferences = ObservedObject(wrappedValue: preferences)
    }

    public var body: some View {
        Form {
            Section {
                Picker("Distance Units", selection: $preferences.distanceUnit) {
                    ForEach(AppDistanceUnitPreference.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }

                Picker("Start Tab", selection: $preferences.startTab) {
                    ForEach(AppStartTabPreference.allCases) { tab in
                        Text(tab.title).tag(tab)
                    }
                }

                Toggle("Show Technical Import Details", isOn: $preferences.showsTechnicalImportDetails)
            } header: {
                Text("Display")
            } footer: {
                Text("Controls how much metadata the app shows around imports and source information.")
            }

            Section {
                Picker("Default Map Style", selection: $preferences.preferredMapStyle) {
                    ForEach(AppMapStylePreference.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
            } header: {
                Text("Maps")
            } footer: {
                Text("Applies to the day-detail map and live-location map.")
            }

            Section {
                LabeledContent("Location Data", value: "Stored locally on this device")
                LabeledContent("Server Upload", value: "Not available")
                LabeledContent("Live Recording", value: "Foreground only")
            } header: {
                Text("Privacy")
            } footer: {
                Text("This app currently has no cloud sync, no server transfer and no background-location workflow.")
            }

            Section {
                Button("Reset Options") {
                    preferences.reset()
                }
                .foregroundStyle(.red)
            } header: {
                Text("Technical")
            }
        }
        .navigationTitle("Options")
    }
}
#endif
