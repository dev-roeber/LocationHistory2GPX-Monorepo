import Foundation

enum SavedTracksPresentation {
    static let libraryTitle = "Saved Tracks"
    static let libraryIcon = "point.topleft.down.curvedto.point.bottomright.up"
    static let editorTitle = "Edit Track"
    static let libraryButtonTitle = "View Library"

    static func overviewMessage(hasTracks: Bool) -> String {
        if hasTracks {
            return "Open the Saved Tracks library to review local recordings and jump into point editing."
        }
        return "Saved Tracks stay separate from imported history. Record a short route on any day, then open the library here."
    }

    static let latestTrackLabel = "Latest saved track"

    static let librarySummaryMessage =
        "Saved tracks are local recordings. They stay separate from imported history until you open one for editing."

    static let libraryEmptyTitle = "No saved tracks yet."
    static let libraryEmptyMessage =
        "Open any day, start Live Recording, then stop recording to add a saved track here."

    static let liveSectionMessage =
        "Local recording, current position and saved tracks stay separate from imported day history."

    static let liveListMessage =
        "Tap a saved track to edit points directly without changing the imported day data above."

    static let liveEmptyMessage =
        "When you stop recording, finished routes appear here and in the Saved Tracks library."

    static let unavailableTitle = "Saved Tracks Unavailable"
    static let unavailableMessage =
        "Saved tracks can be viewed and edited on platforms that support the track library."
}
