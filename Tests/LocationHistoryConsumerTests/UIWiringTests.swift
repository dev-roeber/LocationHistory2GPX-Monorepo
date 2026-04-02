import XCTest
@testable import LocationHistoryConsumerAppSupport
import LocationHistoryConsumer

/// Tests for the UI wiring of the 9-feature batch (2026-04-01).
/// Non-UI logic and helpers are tested here; pure SwiftUI rendering
/// is verified manually on an Apple host device.
final class UIWiringTests: XCTestCase {

    // MARK: - HistoryDateRangeFilter chipLabel

    func testChipLabelAllReturnsLocalizedAllDays() {
        let filter = HistoryDateRangeFilter(preset: .all)
        XCTAssertEqual(filter.chipLabel, "All Time")
    }

    func testChipLabelLast7DaysIsCorrect() {
        let filter = HistoryDateRangeFilter(preset: .last7Days)
        XCTAssertEqual(filter.chipLabel, "Last 7 days")
    }

    func testChipLabelCustomWithoutDatesReturnsCustom() {
        let filter = HistoryDateRangeFilter(preset: .custom, customStart: nil, customEnd: nil)
        XCTAssertEqual(filter.chipLabel, "Custom")
    }

    func testChipLabelCustomWithDatesIsFormatted() {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: 2025, month: 3, day: 31))!
        let filter = HistoryDateRangeFilter(preset: .custom, customStart: start, customEnd: end)
        // Should contain the two dates separated by " – "
        XCTAssertTrue(filter.chipLabel.contains("–"))
    }

    func testIsActiveFalseForAllPreset() {
        let filter = HistoryDateRangeFilter(preset: .all)
        XCTAssertFalse(filter.isActive)
    }

    func testIsActiveTrueForNonAllPreset() {
        let filter = HistoryDateRangeFilter(preset: .last30Days)
        XCTAssertTrue(filter.isActive)
    }

    func testResetResetsToDefault() {
        var filter = HistoryDateRangeFilter(preset: .last90Days)
        filter.reset()
        XCTAssertEqual(filter, HistoryDateRangeFilter.default)
    }

    // MARK: - DayListFilter chip filtering

    func testDayListFilterPassesWithNoActiveChips() {
        let filter = DayListFilter()
        let summary = DaySummary.stub(date: "2024-01-01", visitCount: 0, pathCount: 0)
        XCTAssertTrue(filter.passes(summary: summary, isFavorited: false))
    }

    func testDayListFilterFavoritesChipRequiresFavorite() {
        var filter = DayListFilter()
        filter.toggle(.favorites)
        let summary = DaySummary.stub(date: "2024-01-01", visitCount: 1)
        XCTAssertFalse(filter.passes(summary: summary, isFavorited: false))
        XCTAssertTrue(filter.passes(summary: summary, isFavorited: true))
    }

    func testDayListFilterHasRoutesChip() {
        var filter = DayListFilter()
        filter.toggle(.hasRoutes)
        let withRoutes = DaySummary.stub(date: "2024-01-01", pathCount: 2)
        let withoutRoutes = DaySummary.stub(date: "2024-01-01", pathCount: 0)
        XCTAssertTrue(filter.passes(summary: withRoutes, isFavorited: false))
        XCTAssertFalse(filter.passes(summary: withoutRoutes, isFavorited: false))
    }

    func testDayListFilterClearAllRemovesChips() {
        var filter = DayListFilter(activeChips: [.favorites, .hasRoutes, .hasVisits])
        filter.clearAll()
        XCTAssertFalse(filter.isActive)
        XCTAssertTrue(filter.activeChips.isEmpty)
    }

    // MARK: - InsightsDrilldownTarget factory

    func testDrilldownTargetsForDateProducesShowAndExport() {
        let targets = InsightsDrilldownTarget.drilldownTargets(for: "2024-06-15")
        XCTAssertEqual(targets.count, 2)
        // First target navigates to days
        if case let .filterDaysToDate(date) = targets[0].action {
            XCTAssertEqual(date, "2024-06-15")
        } else {
            XCTFail("Expected filterDaysToDate action")
        }
        // Second target prefills export
        if case let .prefillExportForDate(date) = targets[1].action {
            XCTAssertEqual(date, "2024-06-15")
        } else {
            XCTFail("Expected prefillExportForDate action")
        }
    }

    // MARK: - ExportSelectionState per-route selection

    func testRouteSelectionDefaultIsAllSelected() {
        let selection = ExportSelectionState()
        XCTAssertTrue(selection.isRouteSelected(day: "2024-01-01", routeIndex: 0))
        XCTAssertTrue(selection.isRouteSelected(day: "2024-01-01", routeIndex: 5))
    }

    func testRouteSelectionAfterToggleIsTracked() {
        var selection = ExportSelectionState()
        // Simple toggleRoute uses an inclusion model: first call explicitly adds the route.
        selection.toggleRoute(day: "2024-01-01", routeIndex: 0)
        XCTAssertTrue(selection.isRouteSelected(day: "2024-01-01", routeIndex: 0))
        // Second toggle removes from explicit set; empty set → route no longer selected.
        selection.toggleRoute(day: "2024-01-01", routeIndex: 0)
        XCTAssertFalse(selection.isRouteSelected(day: "2024-01-01", routeIndex: 0))
    }

    func testEffectiveRouteIndicesReturnsAllWhenNoExplicitSelection() {
        let selection = ExportSelectionState()
        let indices = selection.effectiveRouteIndices(day: "2024-01-01", allCount: 3)
        XCTAssertEqual(indices.count, 3)
    }

    func testEffectiveRouteIndicesReturnsSubsetAfterToggle() {
        var selection = ExportSelectionState()
        // Deselect route 1 via the availableRouteIndices overload (starts from implicit all).
        selection.toggleRoute(day: "2024-01-01", routeIndex: 1, availableRouteIndices: [0, 1, 2])
        let indices = selection.effectiveRouteIndices(day: "2024-01-01", allCount: 3)
        XCTAssertFalse(indices.contains(1))
        // Routes 0 and 2 are still in the effective subset.
        XCTAssertTrue(indices.contains(0))
    }

    func testClearRouteSelectionRevertsToAllImplicit() {
        var selection = ExportSelectionState()
        selection.toggleRoute(day: "2024-01-01", routeIndex: 0)
        selection.clearRouteSelection(day: "2024-01-01")
        XCTAssertTrue(selection.isRouteSelected(day: "2024-01-01", routeIndex: 0))
        XCTAssertNil(selection.routeSelections["2024-01-01"])
    }

    // MARK: - CSVDocument init

    func testCSVDocumentStoresContent() {
        #if canImport(SwiftUI) && canImport(UniformTypeIdentifiers)
        let csv = CSVDocument(content: "a,b,c\n1,2,3", suggestedFilename: "test.csv")
        XCTAssertEqual(csv.content, "a,b,c\n1,2,3")
        XCTAssertEqual(csv.suggestedFilename, "test.csv")
        #endif
    }

    // MARK: - AutoRestore preference default

    func testAutoRestoreDefaultIsFalse() {
        let suiteName = "UIWiringTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)
            XCTAssertFalse(preferences.autoRestoreLastImport)
        }
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testAutoRestoreCanBeToggled() {
        let suiteName = "UIWiringTests-autoRestore-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)
            preferences.autoRestoreLastImport = true
            XCTAssertTrue(preferences.autoRestoreLastImport)
            preferences.autoRestoreLastImport = false
            XCTAssertFalse(preferences.autoRestoreLastImport)
        }
        defaults.removePersistentDomain(forName: suiteName)
    }
}

// MARK: - DaySummary test stub

private extension DaySummary {
    static func stub(
        date: String,
        visitCount: Int = 0,
        activityCount: Int = 0,
        pathCount: Int = 0,
        totalPathDistanceM: Double = 0
    ) -> DaySummary {
        DaySummary(
            date: date,
            visitCount: visitCount,
            activityCount: activityCount,
            pathCount: pathCount,
            totalPathPointCount: 0,
            totalPathDistanceM: totalPathDistanceM,
            hasContent: visitCount > 0 || activityCount > 0 || pathCount > 0
        )
    }
}
