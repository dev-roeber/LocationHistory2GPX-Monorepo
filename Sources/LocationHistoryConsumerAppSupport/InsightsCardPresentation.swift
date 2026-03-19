#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer

struct InsightsHighlightItem: Identifiable {
    let id: String
    let date: String
    let icon: String
    let color: Color
    let card: InsightsHighlightCardPresentation
}

struct InsightsMetricPresentation: Identifiable, Equatable {
    let id: String
    let icon: String
    let text: String
    let accessibilityLabel: String
}

struct InsightsHighlightCardPresentation: Equatable {
    let title: String
    let value: String
    let dateText: String
    let subtitle: String?
    let metrics: [InsightsMetricPresentation]
    let accessibilityLabel: String
}

struct InsightsTopDayRowPresentation: Equatable {
    let rankText: String
    let dateText: String
    let weekdayText: String
    let primaryValue: String
    let subtitle: String?
    let metrics: [InsightsMetricPresentation]
    let accessibilityLabel: String
}

enum InsightsCardPresentation {
    static func highlightItem(
        id: String,
        title: String,
        icon: String,
        color: Color,
        highlight: DayHighlight,
        summary: DaySummary?,
        unit: AppDistanceUnitPreference
    ) -> InsightsHighlightItem {
        InsightsHighlightItem(
            id: id,
            date: highlight.date,
            icon: icon,
            color: color,
            card: highlightCard(
                title: title,
                value: highlightValue(highlight, summary: summary, unit: unit),
                date: highlight.date,
                summary: summary,
                unit: unit
            )
        )
    }

    static func highlightCard(
        title: String,
        value: String,
        date: String,
        summary: DaySummary?,
        unit: AppDistanceUnitPreference
    ) -> InsightsHighlightCardPresentation {
        let dateText = AppDateDisplay.mediumDate(date)
        let subtitle = summary.map { supportingSummaryText(for: $0, unit: unit) }
        let metrics = summary.map { supportingMetrics(for: $0, unit: unit) } ?? []
        let accessibilityParts = [title, value, dateText, subtitle]
            .compactMap { $0 } + metrics.map(\.accessibilityLabel)

        return InsightsHighlightCardPresentation(
            title: title,
            value: value,
            dateText: dateText,
            subtitle: subtitle,
            metrics: metrics,
            accessibilityLabel: accessibilityParts.joined(separator: ", ")
        )
    }

    static func topDayRow(
        summary: DaySummary,
        rank: Int,
        metric: InsightsTopDayMetric,
        unit: AppDistanceUnitPreference
    ) -> InsightsTopDayRowPresentation {
        let dateText = AppDateDisplay.mediumDate(summary.date)
        let weekdayText = AppDateDisplay.weekday(summary.date)
        let primaryValue = primaryValue(for: summary, metric: metric, unit: unit)
        let subtitle = subtitle(for: metric)
        let metrics = supportingMetrics(for: summary, unit: unit)
        let accessibilityParts = [
            "Rank \(rank)",
            dateText,
            primaryValue,
            subtitle
        ].compactMap { $0 } + metrics.map(\.accessibilityLabel)

        return InsightsTopDayRowPresentation(
            rankText: "\(rank)",
            dateText: dateText,
            weekdayText: weekdayText,
            primaryValue: primaryValue,
            subtitle: subtitle,
            metrics: metrics,
            accessibilityLabel: accessibilityParts.joined(separator: ", ")
        )
    }

    static func supportingMetrics(
        for summary: DaySummary,
        unit: AppDistanceUnitPreference
    ) -> [InsightsMetricPresentation] {
        var metrics: [InsightsMetricPresentation] = []
        if summary.visitCount > 0 {
            metrics.append(
                .init(
                    id: "visits",
                    icon: "mappin.and.ellipse",
                    text: "\(summary.visitCount) \(summary.visitCount == 1 ? "visit" : "visits")",
                    accessibilityLabel: "\(summary.visitCount) \(summary.visitCount == 1 ? "visit" : "visits")"
                )
            )
        }
        if summary.activityCount > 0 {
            metrics.append(
                .init(
                    id: "activities",
                    icon: "figure.walk",
                    text: "\(summary.activityCount) \(summary.activityCount == 1 ? "activity" : "activities")",
                    accessibilityLabel: "\(summary.activityCount) \(summary.activityCount == 1 ? "activity" : "activities")"
                )
            )
        }
        if summary.pathCount > 0 {
            metrics.append(
                .init(
                    id: "routes",
                    icon: "location.north.line",
                    text: "\(summary.pathCount) \(summary.pathCount == 1 ? "route" : "routes")",
                    accessibilityLabel: "\(summary.pathCount) \(summary.pathCount == 1 ? "route" : "routes")"
                )
            )
        }
        if summary.totalPathDistanceM > 0 {
            let distance = formatDistance(summary.totalPathDistanceM, unit: unit)
            metrics.append(
                .init(
                    id: "distance",
                    icon: "ruler",
                    text: distance,
                    accessibilityLabel: "\(distance) route distance"
                )
            )
        }
        return metrics
    }

    private static func primaryValue(
        for summary: DaySummary,
        metric: InsightsTopDayMetric,
        unit: AppDistanceUnitPreference
    ) -> String {
        switch metric {
        case .events:
            let total = summary.visitCount + summary.activityCount + summary.pathCount
            return "\(total) event\(total == 1 ? "" : "s")"
        case .visits:
            return "\(summary.visitCount) visit\(summary.visitCount == 1 ? "" : "s")"
        case .routes:
            return "\(summary.pathCount) route\(summary.pathCount == 1 ? "" : "s")"
        case .distance:
            return formatDistance(summary.totalPathDistanceM, unit: unit)
        }
    }

    private static func subtitle(for metric: InsightsTopDayMetric) -> String {
        switch metric {
        case .events:
            return "Visits, activities and routes combined"
        case .visits:
            return "Highest semantic visit count"
        case .routes:
            return "Most recorded routes in one day"
        case .distance:
            return "Longest imported route distance"
        }
    }

    private static func supportingSummaryText(
        for summary: DaySummary,
        unit: AppDistanceUnitPreference
    ) -> String {
        let eventCount = summary.visitCount + summary.activityCount + summary.pathCount
        let pointSummary = summary.totalPathPointCount > 0
            ? "\(summary.totalPathPointCount) point\(summary.totalPathPointCount == 1 ? "" : "s")"
            : nil
        let eventSummary = "\(eventCount) \(eventCount == 1 ? "event" : "events")"
        if summary.totalPathDistanceM > 0 {
            return [eventSummary, formatDistance(summary.totalPathDistanceM, unit: unit), pointSummary]
                .compactMap { $0 }
                .joined(separator: " · ")
        }
        return [eventSummary, pointSummary]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    private static func highlightValue(
        _ highlight: DayHighlight,
        summary: DaySummary?,
        unit: AppDistanceUnitPreference
    ) -> String {
        guard let summary,
              summary.totalPathDistanceM > 0,
              highlight.value.localizedCaseInsensitiveContains("km") || highlight.value.localizedCaseInsensitiveContains("mi") else {
            return highlight.value
        }
        return formatDistance(summary.totalPathDistanceM, unit: unit)
    }
}

struct InsightsMetricChipsView: View {
    let metrics: [InsightsMetricPresentation]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
            ForEach(metrics) { metric in
                HStack(spacing: 6) {
                    Image(systemName: metric.icon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(metric.text)
                        .font(.caption.monospacedDigit())
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.secondary.opacity(0.08))
                .clipShape(Capsule())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(metric.accessibilityLabel)
            }
        }
    }
}

struct InsightsHighlightCardView: View {
    let item: InsightsHighlightItem
    let isInteractive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: item.icon)
                    .foregroundStyle(item.color)
                    .font(.caption)
                Text(item.card.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                if isInteractive {
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(item.color.opacity(0.55))
                }
            }

            Text(item.card.value)
                .font(.headline.monospacedDigit())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.card.dateText)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                if let subtitle = item.card.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }

            if !item.card.metrics.isEmpty {
                InsightsMetricChipsView(metrics: item.card.metrics)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(item.color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.card.accessibilityLabel)
        .accessibilityAddTraits(isInteractive ? .isButton : [])
    }
}

struct InsightsTopDayRowView: View {
    let presentation: InsightsTopDayRowPresentation
    let accent: Color
    let isInteractive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(presentation.rankText)
                .font(.headline.monospacedDigit())
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(presentation.weekdayText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(presentation.dateText)
                        .font(.subheadline.weight(.semibold))
                    Text(presentation.primaryValue)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.primary)
                    if let subtitle = presentation.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !presentation.metrics.isEmpty {
                    InsightsMetricChipsView(metrics: presentation.metrics)
                }
            }

            Spacer(minLength: 12)

            if isInteractive {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(accent.opacity(0.6))
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(accent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(presentation.accessibilityLabel)
        .accessibilityAddTraits(isInteractive ? .isButton : [])
    }
}

#endif
