import XCTest
import LocationHistoryConsumer
@testable import LocationHistoryConsumerAppSupport

final class InsightsChartSupportTests: XCTestCase {
    func testAvailableActivityMetricsOnlyShowsDistanceWhenPresent() {
        let withoutDistance = [
            ActivityBreakdownItem(activityType: "WALKING", count: 2, totalDistanceKM: 0, totalDurationH: 0.5, avgSpeedKMH: 0),
        ]
        let withDistance = [
            ActivityBreakdownItem(activityType: "WALKING", count: 2, totalDistanceKM: 1.2, totalDurationH: 0.5, avgSpeedKMH: 4.2),
        ]

        XCTAssertEqual(InsightsChartSupport.availableActivityMetrics(for: withoutDistance), [.count])
        XCTAssertEqual(InsightsChartSupport.availableActivityMetrics(for: withDistance), [.count, .distance])
    }

    func testDistanceMessagesDifferentiateNavigationAndMissingData() {
        XCTAssertEqual(
            InsightsChartSupport.distanceSectionMessage(hasDays: true, canNavigateToDay: true),
            "Route distances only. Tap a bar to open that day."
        )
        XCTAssertEqual(
            InsightsChartSupport.distanceSectionMessage(hasDays: true, canNavigateToDay: false),
            "Route distances only."
        )
        XCTAssertEqual(
            InsightsChartSupport.distanceEmptyMessage(),
            "No route distance data is available for these days."
        )
    }

    func testWeekdayMessageExplainsLowDataThresholds() {
        XCTAssertEqual(
            InsightsChartSupport.weekdaySectionMessage(dayCount: 2, bucketCount: 2),
            "Need at least 3 days before a weekday pattern is meaningful."
        )
        XCTAssertEqual(
            InsightsChartSupport.weekdaySectionMessage(dayCount: 5, bucketCount: 1),
            "Need data across multiple weekdays before this chart becomes useful."
        )
        XCTAssertNil(InsightsChartSupport.weekdaySectionMessage(dayCount: 5, bucketCount: 3))
    }

    func testOverviewStateDistinguishesNoDaysAndSparseExports() {
        XCTAssertEqual(
            InsightsChartSupport.overviewState(
                dayCount: 0,
                hasDistanceData: false,
                hasActivityData: false,
                hasVisitData: false,
                hasPeriodData: false
            ),
            .noDays
        )
        XCTAssertEqual(
            InsightsChartSupport.overviewState(
                dayCount: 1,
                hasDistanceData: false,
                hasActivityData: false,
                hasVisitData: false,
                hasPeriodData: false
            ),
            .sparseHistory(dayCount: 1)
        )
        XCTAssertEqual(
            InsightsChartSupport.overviewState(
                dayCount: 2,
                hasDistanceData: false,
                hasActivityData: false,
                hasVisitData: false,
                hasPeriodData: false
            ),
            .ready
        )
    }

    func testSectionMessagesCoverMissingAggregates() {
        XCTAssertEqual(
            InsightsChartSupport.dailyAveragesSectionMessage(dayCount: 1),
            "Need at least 2 days before per-day averages become useful."
        )
        XCTAssertNil(InsightsChartSupport.dailyAveragesSectionMessage(dayCount: 2))
        XCTAssertEqual(
            InsightsChartSupport.activitySectionEmptyMessage(),
            "No activity totals are available for these days."
        )
        XCTAssertEqual(
            InsightsChartSupport.visitSectionEmptyMessage(),
            "No semantic visit categories are available for these days."
        )
        XCTAssertEqual(
            InsightsChartSupport.periodSectionEmptyMessage(),
            "This export does not include any period breakdown stats."
        )
    }

    func testNearestDayChoosesClosestISODate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let tapped = formatter.date(from: "2024-05-02 18:00")!

        let result = InsightsChartSupport.nearestDayISODate(
            to: tapped,
            in: ["2024-05-01", "2024-05-03", "2024-05-10"]
        )

        XCTAssertEqual(result, "2024-05-03")
    }
}
