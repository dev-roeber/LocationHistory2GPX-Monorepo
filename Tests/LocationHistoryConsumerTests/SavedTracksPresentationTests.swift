import XCTest
@testable import LocationHistoryConsumerAppSupport

final class SavedTracksPresentationTests: XCTestCase {
    func testUsesSavedTracksForLibraryAccess() {
        XCTAssertEqual(SavedTracksPresentation.libraryTitle, "Saved Tracks")
        XCTAssertEqual(SavedTracksPresentation.libraryButtonTitle, "View Library")
        XCTAssertEqual(SavedTracksPresentation.editorTitle, "Edit Track")
    }

    func testOverviewMessagesDifferentiateEmptyAndPopulatedLibrary() {
        let emptyMessage = SavedTracksPresentation.overviewMessage(hasTracks: false)
        let populatedMessage = SavedTracksPresentation.overviewMessage(hasTracks: true)

        XCTAssertTrue(emptyMessage.contains("Saved Tracks"))
        XCTAssertTrue(emptyMessage.contains("separate from imported history"))
        XCTAssertTrue(populatedMessage.contains("Saved Tracks library"))
        XCTAssertTrue(populatedMessage.contains("point editing"))
    }

    func testLiveAndUnavailableMessagesStayAlignedToLibraryNaming() {
        XCTAssertTrue(SavedTracksPresentation.liveEmptyMessage.contains("Saved Tracks library"))
        XCTAssertTrue(SavedTracksPresentation.liveListMessage.contains("edit points directly"))
        XCTAssertEqual(SavedTracksPresentation.unavailableTitle, "Saved Tracks Unavailable")
        XCTAssertTrue(SavedTracksPresentation.unavailableMessage.contains("track library"))
    }
}
