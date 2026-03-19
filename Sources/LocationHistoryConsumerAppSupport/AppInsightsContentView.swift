#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer
#if canImport(Charts)
import Charts
#endif

struct AppInsightsContentView: View {
    @EnvironmentObject private var preferences: AppPreferences
    let insights: ExportInsights
    let daySummaries: [DaySummary]
    let onDayTap: ((String) -> Void)?
    @State private var activityMetric: ActivityMetric = .count

    private static let chartDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(insights: ExportInsights, daySummaries: [DaySummary] = [], onDayTap: ((String) -> Void)? = nil) {
        self.insights = insights
        self.daySummaries = daySummaries
        self.onDayTap = onDayTap
    }

    private struct WeekdayStat: Identifiable {
        let id: Int
        let name: String
        let avgEvents: Double
    }

    private var weekdayStats: [WeekdayStat] {
        guard daySummaries.count >= InsightsChartSupport.minimumDaysForWeekdayChart else { return [] }
        var buckets: [Int: (total: Int, count: Int)] = [:]
        for summary in daySummaries {
            guard let date = Self.chartDateFormatter.date(from: summary.date) else { continue }
            let wd = Calendar.current.component(.weekday, from: date)
            let events = summary.visitCount + summary.activityCount
            let b = buckets[wd] ?? (total: 0, count: 0)
            buckets[wd] = (total: b.total + events, count: b.count + 1)
        }
        // Mon(2)..Sat(7), Sun(1) last
        let order = [2, 3, 4, 5, 6, 7, 1]
        let names = [1: "Sun", 2: "Mon", 3: "Tue", 4: "Wed", 5: "Thu", 6: "Fri", 7: "Sat"]
        return order.compactMap { wd in
            guard let b = buckets[wd], b.count > 0 else { return nil }
            return WeekdayStat(id: wd, name: names[wd]!, avgEvents: Double(b.total) / Double(b.count))
        }
    }

    private var availableActivityMetrics: [ActivityMetric] {
        InsightsChartSupport.availableActivityMetrics(for: insights.activityBreakdown)
    }

    private var hasDistanceData: Bool {
        InsightsChartSupport.hasDistanceData(in: daySummaries)
    }

    private var displayedActivityMetric: ActivityMetric {
        availableActivityMetrics.contains(activityMetric) ? activityMetric : availableActivityMetrics.first ?? .count
    }

    private var overviewState: InsightsOverviewState {
        InsightsChartSupport.overviewState(
            dayCount: daySummaries.count,
            hasDistanceData: hasDistanceData,
            hasActivityData: !insights.activityBreakdown.isEmpty,
            hasVisitData: !insights.visitTypeBreakdown.isEmpty,
            hasPeriodData: !insights.periodBreakdown.isEmpty
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch overviewState {
            case .noDays:
                overviewEmptyState(overviewState)
            case .sparseHistory:
                overviewEmptyState(overviewState)
                insightsSections
            case .ready:
                insightsSections
            }
        }
    }

    @ViewBuilder
    private var insightsSections: some View {
            // Distance Over Time
            #if canImport(Charts)
            if !daySummaries.isEmpty {
                insightSection("Distance Over Time", icon: "chart.bar.fill") {
                    if hasDistanceData {
                        distanceChart
                    } else {
                        chartEmptyState(
                            title: "No Distance Data",
                            message: InsightsChartSupport.distanceEmptyMessage(),
                            systemImage: "road.lanes"
                        )
                    }
                    Text(InsightsChartSupport.distanceSectionMessage(hasDays: !daySummaries.isEmpty, canNavigateToDay: onDayTap != nil))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            #endif

            // Daily Averages (only meaningful with multiple days)
            insightSection("Daily Averages", icon: "chart.bar.fill") {
                if let message = InsightsChartSupport.dailyAveragesSectionMessage(dayCount: daySummaries.count) {
                    chartEmptyState(
                        title: "Daily Averages Not Ready",
                        message: message,
                        systemImage: "calendar.badge.clock"
                    )
                } else {
                    let avg = insights.averagesPerDay
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                        avgCard(String(format: "%.1f", avg.avgVisitsPerDay), label: "Visits / Day", icon: "mappin.and.ellipse", color: .blue)
                        avgCard(String(format: "%.1f", avg.avgActivitiesPerDay), label: "Activities / Day", icon: "figure.walk", color: .green)
                        avgCard(String(format: "%.1f", avg.avgPathsPerDay), label: "Routes / Day", icon: "location.north.line", color: .orange)
                        avgCard(formatDistance(avg.avgDistancePerDayM, unit: preferences.distanceUnit), label: "Distance / Day", icon: "road.lanes", color: .purple)
                    }
                }
            }

            // Activity Types
            insightSection("Activity Types", icon: "figure.walk") {
                if insights.activityBreakdown.isEmpty {
                    chartEmptyState(
                        title: "No Activity Breakdown",
                        message: InsightsChartSupport.activitySectionEmptyMessage(),
                        systemImage: "figure.walk"
                    )
                } else {
                    #if canImport(Charts)
                    if availableActivityMetrics.count > 1 {
                        Picker("", selection: $activityMetric) {
                            ForEach(availableActivityMetrics, id: \.self) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 4)
                    }
                    activityTypeChart(metric: displayedActivityMetric)
                    if availableActivityMetrics.count == 1 {
                        Text("Distance mode appears when exported activity totals include route distance.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    #endif
                    ForEach(Array(insights.activityBreakdown.enumerated()), id: \.offset) { _, item in
                        activityBreakdownCard(item)
                    }
                }
            }

            // Visit Types
            insightSection("Visit Types", icon: "mappin.and.ellipse") {
                if insights.visitTypeBreakdown.isEmpty {
                    chartEmptyState(
                        title: "No Visit Breakdown",
                        message: InsightsChartSupport.visitSectionEmptyMessage(),
                        systemImage: "mappin.and.ellipse"
                    )
                } else {
                    #if canImport(Charts)
                    visitTypeChart
                    Text("Counts by semantic visit type.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    #endif
                    ForEach(Array(insights.visitTypeBreakdown.enumerated()), id: \.offset) { _, item in
                        visitTypeRow(item)
                    }
                }
            }

            // By Day of Week
            #if canImport(Charts)
            if !daySummaries.isEmpty {
                insightSection("By Day of Week", icon: "chart.bar") {
                    if let message = InsightsChartSupport.weekdaySectionMessage(dayCount: daySummaries.count, bucketCount: weekdayStats.count) {
                        chartEmptyState(
                            title: "Weekday Pattern Not Ready",
                            message: message,
                            systemImage: "calendar.badge.clock"
                        )
                    } else {
                        weekdayChart
                        Text("Average visits plus activities per weekday.")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            #endif

            // Period Breakdown
            insightSection("Period Breakdown", icon: "calendar.badge.clock") {
                if insights.periodBreakdown.isEmpty {
                    chartEmptyState(
                        title: "No Period Breakdown",
                        message: InsightsChartSupport.periodSectionEmptyMessage(),
                        systemImage: "calendar.badge.clock"
                    )
                } else {
                    ForEach(Array(insights.periodBreakdown.enumerated()), id: \.offset) { _, item in
                        periodRow(item)
                    }
                }
            }
    }

    @ViewBuilder
    private func chartEmptyState(title: String, message: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func overviewEmptyState(_ state: InsightsOverviewState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(state.title, systemImage: state.systemImage)
                .font(.subheadline.weight(.semibold))
            Text(state.message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func insightSection<Content: View>(
        _ title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title3.weight(.semibold))
            content()
        }
    }

    @ViewBuilder
    private func avgCard(_ value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.monospacedDigit())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private func activityBreakdownCard(_ item: ActivityBreakdownItem) -> some View {
        let color = colorForActivityType(item.activityType)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForActivityType(item.activityType))
                    .foregroundColor(color)
                    .font(.subheadline)
                Text(displayNameForActivityType(item.activityType))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(item.count)×")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.12))
                    .clipShape(Capsule())
            }
            HStack(spacing: 16) {
                if item.totalDistanceKM > 0 {
                    Label(formatDistance(item.totalDistanceKM * 1000, unit: preferences.distanceUnit), systemImage: "ruler")
                }
                if item.totalDurationH > 0 {
                    Label(formatDuration(item.totalDurationH), systemImage: "clock")
                }
                if item.avgSpeedKMH > 0 {
                    Label(formatSpeed(item.avgSpeedKMH, unit: preferences.distanceUnit), systemImage: "speedometer")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func visitTypeRow(_ item: VisitTypeItem) -> some View {
        HStack {
            Image(systemName: iconForVisitType(item.semanticType))
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(item.semanticType.capitalized)
                .font(.subheadline)
            Spacer()
            Text("\(item.count)")
                .font(.subheadline.weight(.medium).monospacedDigit())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.08))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func periodRow(_ item: PeriodBreakdownItem) -> some View {
        let periodColor = item.distanceM > 0 ? Color.purple : Color.secondary
        VStack(alignment: .leading, spacing: 6) {
            Text(item.label)
                .font(.subheadline.weight(.medium))
            HStack(spacing: 16) {
                Label("\(item.days) days", systemImage: "calendar")
                Label("\(item.visits) visits", systemImage: "mappin.and.ellipse")
                if item.distanceM > 0 {
                    Label(formatDistance(item.distanceM, unit: preferences.distanceUnit), systemImage: "ruler")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(periodColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Charts

    #if canImport(Charts)
    @ViewBuilder
    private var distanceChart: some View {
        Chart {
            ForEach(daySummaries, id: \.date) { summary in
                if let date = Self.chartDateFormatter.date(from: summary.date) {
                    BarMark(
                        x: .value("Date", date, unit: .day),
                        y: .value(distanceAxisLabel(unit: preferences.distanceUnit), distanceValue(summary.totalPathDistanceM, unit: preferences.distanceUnit))
                    )
                    .foregroundStyle(Color.accentColor)
                    .cornerRadius(3)
                }
            }
        }
        .chartXAxis {
            distanceChartXAxis
        }
        .chartYAxisLabel(distanceAxisLabel(unit: preferences.distanceUnit), alignment: .trailing)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        guard let onDayTap else { return }
                        let x = location.x - geometry.frame(in: .local).minX
                        guard let tappedDate: Date = proxy.value(atX: x),
                              let iso = InsightsChartSupport.nearestDayISODate(to: tappedDate, in: daySummaries.map(\.date)) else {
                            return
                        }
                        onDayTap(iso)
                    }
            }
        }
        .frame(height: 170)
    }

    @AxisContentBuilder
    private var distanceChartXAxis: some AxisContent {
        if daySummaries.count <= 7 {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        } else if daySummaries.count <= 31 {
            AxisMarks(values: .stride(by: .weekOfMonth)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        } else {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }

    @ViewBuilder
    private func activityTypeChart(metric: ActivityMetric) -> some View {
        let items = insights.activityBreakdown
        let showDistance = metric == .distance
        Chart {
            ForEach(items, id: \.activityType) { item in
                let xVal = showDistance ? distanceValue(item.totalDistanceKM * 1000, unit: preferences.distanceUnit) : Double(item.count)
                BarMark(
                    x: .value(showDistance ? distanceAxisLabel(unit: preferences.distanceUnit) : "Count", xVal),
                    y: .value("Type", item.activityType.capitalized)
                )
                .foregroundStyle(Color.green)
                .cornerRadius(4)
                .annotation(position: .trailing) {
                    Text(showDistance ? String(format: "%.1f", distanceValue(item.totalDistanceKM * 1000, unit: preferences.distanceUnit)) : "\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom)
        }
        .chartXAxisLabel(showDistance ? distanceAxisLabel(unit: preferences.distanceUnit) : "count")
        .frame(height: CGFloat(max(items.count, 1)) * 44 + 18)
    }

    @ViewBuilder
    private var visitTypeChart: some View {
        let totalCount = insights.visitTypeBreakdown.reduce(0) { $0 + $1.count }
        if totalCount > 0 {
            Chart {
                ForEach(insights.visitTypeBreakdown, id: \.semanticType) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Type", item.semanticType.capitalized)
                    )
                    .foregroundStyle(Color.blue)
                    .cornerRadius(4)
                    .annotation(position: .trailing) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartXAxisLabel("count")
            .frame(height: CGFloat(max(insights.visitTypeBreakdown.count, 1)) * 44 + 18)
        }
    }

    @ViewBuilder
    private var weekdayChart: some View {
        Chart {
            ForEach(weekdayStats) { stat in
                BarMark(
                    x: .value("Day", stat.name),
                    y: .value("Avg", stat.avgEvents)
                )
                .foregroundStyle(Color.indigo)
                .cornerRadius(4)
                .annotation(position: .top) {
                    Text(String(format: "%.1f", stat.avgEvents))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYAxisLabel("avg events", alignment: .trailing)
        .frame(height: 130)
        .padding(.bottom, 2)
    }
    #endif

    private func formatDuration(_ hours: Double) -> String {
        if hours < 1 {
            return String(format: "%.0f min", hours * 60)
        }
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}

#endif
