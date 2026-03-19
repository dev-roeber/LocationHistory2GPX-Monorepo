import Foundation
import LocationHistoryConsumer

enum ActivityMetric: String, CaseIterable {
    case count = "Count"
    case distance = "Distance"
}

enum InsightsChartSupport {
    static let minimumDaysForWeekdayChart = 3

    static func hasDistanceData(in daySummaries: [DaySummary]) -> Bool {
        daySummaries.contains(where: { $0.totalPathDistanceM > 0 })
    }

    static func availableActivityMetrics(for items: [ActivityBreakdownItem]) -> [ActivityMetric] {
        items.contains(where: { $0.totalDistanceKM > 0 }) ? [.count, .distance] : [.count]
    }

    static func distanceSectionMessage(hasDays: Bool, canNavigateToDay: Bool) -> String {
        if !hasDays {
            return "No day summaries are available for this chart."
        }
        if canNavigateToDay {
            return "Route distances only. Tap a bar to open that day."
        }
        return "Route distances only."
    }

    static func distanceEmptyMessage() -> String {
        "No route distance data is available for these days."
    }

    static func weekdaySectionMessage(dayCount: Int, bucketCount: Int) -> String? {
        guard dayCount < minimumDaysForWeekdayChart || bucketCount < 2 else {
            return nil
        }
        if dayCount < minimumDaysForWeekdayChart {
            return "Need at least 3 days before a weekday pattern is meaningful."
        }
        return "Need data across multiple weekdays before this chart becomes useful."
    }

    static func nearestDayISODate(to tappedDate: Date, in isoDates: [String]) -> String? {
        let candidates = isoDates.compactMap { iso -> (iso: String, date: Date)? in
            guard let date = isoDateFormatter.date(from: iso) else { return nil }
            return (iso, date)
        }

        return candidates.min {
            abs($0.date.timeIntervalSince(tappedDate)) < abs($1.date.timeIntervalSince(tappedDate))
        }?.iso
    }

    private static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
