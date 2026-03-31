import XCTest

final class LH2GPXWrapperUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - App Store Screenshots
    //
    // Run on iPhone 17 Pro Max for iphone/ screenshots.
    // Run on iPad Pro 13-inch (M5) for ipad/ screenshots.
    //
    // The output path suffix (iphone/ipad) must be adjusted per run.

    @MainActor
    func testAppStoreScreenshots() throws {
        // Adjust per simulator run: "iphone" or "ipad"
        let deviceFolder = "iphone"
        let outputDir = FileManager.default.temporaryDirectory.appendingPathComponent("lh2gpx_screenshots/\(deviceFolder)").path
        try FileManager.default.createDirectory(
            atPath: outputDir, withIntermediateDirectories: true
        )

        let app = XCUIApplication()
        app.launch()
        sleep(1)

        // 1. Import / empty state
        saveScreenshot(app, to: "\(outputDir)/01_import_state.png")

        // 2. Load Demo Data
        let demoButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Demo Data'")
        ).firstMatch
        guard demoButton.waitForExistence(timeout: 5) else {
            XCTFail("Demo button not found"); return
        }
        demoButton.tap()
        sleep(3)

        // On iPhone: go back to see the day list (auto-navigates to detail)
        // On iPad: back button may not exist – skip
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.exists && backButton.isHittable {
            backButton.tap()
            sleep(1)
        }

        // 3. Day list / overview
        saveScreenshot(app, to: "\(outputDir)/02_day_list.png")

        // 4. Tap first day cell (non-fatal: iPad may not need tap)
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            sleep(2)
        }

        // 5. Day detail – top (map)
        saveScreenshot(app, to: "\(outputDir)/03_day_detail.png")

        // 6. Day detail – scrolled (stats + sections)
        app.swipeUp()
        sleep(1)
        saveScreenshot(app, to: "\(outputDir)/04_day_detail_stats.png")
    }

    // MARK: - Helpers

    private func saveScreenshot(_ app: XCUIApplication, to path: String) {
        let screenshot = XCUIScreen.main.screenshot()
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
        } catch {
            XCTFail("Screenshot save failed: \(error)")
        }
    }
}
