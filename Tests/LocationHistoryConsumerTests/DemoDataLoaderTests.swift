import XCTest
@testable import LocationHistoryConsumerDemoSupport

final class DemoDataLoaderTests: XCTestCase {
    func testLoadsDefaultDemoFixtureAndBuildsOverview() throws {
        let content = try DemoDataLoader.loadDefaultContent()

        XCTAssertEqual(content.overview.schemaVersion, "1.0")
        XCTAssertEqual(content.overview.inputFormat, "records")
        XCTAssertEqual(content.overview.dayCount, 2)
        XCTAssertEqual(content.daySummaries.map(\.date), ["2024-05-01", "2024-05-02"])
        XCTAssertEqual(content.selectedDate, "2024-05-01")
    }

    func testMissingFixtureFailsClearly() {
        XCTAssertThrowsError(try DemoDataLoader.loadContent(named: "does_not_exist")) { error in
            XCTAssertEqual(error.localizedDescription, "Demo fixture not found: does_not_exist.json")
        }
    }
}
