#if canImport(SwiftUI)
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct AppRecordedTracksLibraryView: View {
    @EnvironmentObject private var preferences: AppPreferences
    @ObservedObject private var liveLocation: LiveLocationFeatureModel

    init(liveLocation: LiveLocationFeatureModel) {
        self._liveLocation = ObservedObject(wrappedValue: liveLocation)
    }

    var body: some View {
        List {
            summarySection

            if liveLocation.recordedTracks.isEmpty {
                emptyStateSection
            } else {
                tracksSection
            }
        }
        .navigationTitle(SavedTracksPresentation.libraryTitle)
        .navigationDestination(for: RecordedTrack.self) { track in
            AppRecordedTrackEditorView(track: track, liveLocation: liveLocation)
        }
    }

    private var summarySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Label(SavedTracksPresentation.libraryTitle, systemImage: SavedTracksPresentation.libraryIcon)
                    .font(.headline)
                Text(SavedTracksPresentation.librarySummaryMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyStateSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(SavedTracksPresentation.libraryEmptyTitle)
                    .font(.subheadline.weight(.semibold))
                Text(SavedTracksPresentation.libraryEmptyMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var tracksSection: some View {
        Section(SavedTracksPresentation.libraryTitle) {
            ForEach(liveLocation.recordedTracks) { track in
                NavigationLink(value: track) {
                    HStack(spacing: 10) {
                        Image(systemName: SavedTracksPresentation.libraryIcon)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(savedTrackTitle(track))
                                .font(.subheadline.weight(.semibold))
                            Text("\(track.pointCount) points · \(formatDistance(track.distanceM, unit: preferences.distanceUnit))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func savedTrackTitle(_ track: RecordedTrack) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: track.startedAt)
    }
}
#endif
