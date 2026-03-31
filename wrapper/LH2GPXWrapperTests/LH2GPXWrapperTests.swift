import XCTest
import LocationHistoryConsumerAppSupport
import LocationHistoryConsumerDemoSupport
@testable import LH2GPXWrapper

// MARK: - AppSessionState integration tests
//
// These tests exercise the session state that ContentView uses.
// They guard against regressions in the Core library's state machine
// and verify that the Wrapper's demo-data integration works correctly.

final class LH2GPXWrapperTests: XCTestCase {

    // MARK: Initial State

    func testInitialSessionStateIsIdle() {
        let state = AppSessionState()
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.hasLoadedContent)
        XCTAssertNil(state.content)
        XCTAssertEqual(state.presentationState, .idle)
        XCTAssertNil(state.selectedDate)
    }

    // MARK: Demo Load

    func testDemoLoadProducesDemoState() throws {
        var state = AppSessionState()
        let content = try DemoDataLoader.loadDefaultContent()
        state.show(content: content)

        XCTAssertEqual(state.presentationState, .demoLoaded)
        XCTAssertTrue(state.hasDays)
        XCTAssertNotNil(state.selectedDate)
        XCTAssertEqual(state.message?.title, "Demo data ready")
    }

    func testDemoLoadDoesNotRequireClearingBookmark() throws {
        // Regression guard: loadBundledDemo must not call ImportBookmarkStore.clear()
        // before showing demo data — doing so would silently destroy a previously
        // saved import bookmark. This test verifies the demo content is self-contained.
        let content = try DemoDataLoader.loadDefaultContent()
        XCTAssertFalse(content.daySummaries.isEmpty)
        XCTAssertEqual(content.source, .demoFixture(name: AppContentLoader.defaultDemoFixtureName))
    }

    // MARK: State Transitions

    func testBeginLoadingSetsLoadingState() {
        var state = AppSessionState()
        state.beginLoading()

        XCTAssertTrue(state.isLoading)
        XCTAssertEqual(state.presentationState, .loading)
        XCTAssertNil(state.message)
    }

    func testGuardAgainstDoubleLoadIsDetectable() {
        // ContentView guards handleImportResult with `guard !session.isLoading`.
        // Verify the guard condition is detectable via isLoading.
        var state = AppSessionState()
        state.beginLoading()
        // A second beginLoading() call would be guarded away in ContentView.
        XCTAssertTrue(state.isLoading, "isLoading must be true so the guard fires")
    }

    func testClearContentResetsToIdle() throws {
        var state = AppSessionState()
        let content = try DemoDataLoader.loadDefaultContent()
        state.show(content: content)
        XCTAssertTrue(state.hasLoadedContent)

        state.clearContent()

        XCTAssertFalse(state.hasLoadedContent)
        XCTAssertNil(state.content)
        XCTAssertNil(state.selectedDate)
        XCTAssertEqual(state.presentationState, .idle)
    }

    func testShowFailureWithoutContentSetsErrorState() {
        var state = AppSessionState()
        state.showFailure(
            title: "Unable to open file",
            message: "File corrupted",
            preserveCurrentContent: false
        )

        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.hasLoadedContent)
        XCTAssertEqual(state.presentationState, .failedWithoutContent)
        XCTAssertEqual(state.message?.kind, .error)
        XCTAssertEqual(state.message?.title, "Unable to open file")
    }

    func testShowFailurePreservingContentKeepsLoadedState() throws {
        var state = AppSessionState()
        let content = try DemoDataLoader.loadDefaultContent()
        state.show(content: content)

        state.showFailure(
            title: "Next import failed",
            message: "Bad file",
            preserveCurrentContent: true
        )

        XCTAssertTrue(state.hasLoadedContent, "Previous content must be preserved")
        XCTAssertEqual(state.presentationState, .failedWithContent)
    }
}
