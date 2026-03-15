#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer

public struct AppContentSplitView: View {
    @Binding private var session: AppSessionState
    private let sourceHint: String?

    public init(session: Binding<AppSessionState>, sourceHint: String? = nil) {
        self._session = session
        self.sourceHint = sourceHint
    }

    public var body: some View {
        NavigationSplitView {
            AppDayListView(
                summaries: session.daySummaries,
                selectedDate: Binding(
                    get: { session.selectedDate },
                    set: { session.selectDay($0) }
                )
            )
            .safeAreaInset(edge: .bottom) {
                sourceFooter
            }
            .navigationTitle("Days")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AppSessionStatusView(
                        summary: session.sourceSummary,
                        message: session.message,
                        isLoading: session.isLoading,
                        hasDays: session.hasDays
                    )
                    if let overview = session.overview {
                        AppOverviewSection(overview: overview)
                    }
                    AppDayDetailView(
                        detail: session.selectedDetail,
                        hasDays: session.hasDays
                    )
                }
                .padding()
            }
            .navigationTitle(session.selectedDate ?? "Overview")
        }
    }

    private var sourceFooter: some View {
        Group {
            if let sourceHint, session.hasLoadedContent {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                    Text("Source Actions")
                        .font(.caption.weight(.semibold))
                    Text(sourceHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.thinMaterial)
            }
        }
    }
}

public struct AppSessionStatusView: View {
    let summary: AppSourceSummary
    let message: AppUserMessage?
    let isLoading: Bool
    let hasDays: Bool

    public init(summary: AppSourceSummary, message: AppUserMessage?, isLoading: Bool, hasDays: Bool) {
        self.summary = summary
        self.message = message
        self.isLoading = isLoading
        self.hasDays = hasDays
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppSourceSummaryCard(summary: summary)

            if let message, message.kind == .error {
                AppMessageCard(message: message)
            }

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Processing app export...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !hasDays {
                Text("This app export currently has no day entries. Overview data is still shown above.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

public struct AppSourceSummaryCard: View {
    let summary: AppSourceSummary

    public init(summary: AppSourceSummary) {
        self.summary = summary
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.stateTitle)
                .font(.headline)

            infoRow(summary.sourceLabel, value: summary.sourceValue)

            if let schemaVersion = summary.schemaVersion {
                infoRow("Schema", value: schemaVersion)
            }
            if let inputFormat = summary.inputFormat {
                infoRow("Input Format", value: inputFormat)
            }
            if let exportedAt = summary.exportedAt {
                infoRow("Exported At", value: exportedAt)
            }
            if let dayCountText = summary.dayCountText {
                infoRow("Days", value: dayCountText)
            }

            Text(summary.statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    @ViewBuilder
    private func infoRow(_ label: String, value: String) -> some View {
        LabeledContent(label, value: value)
            .font(.subheadline)
    }
}

public struct AppMessageCard: View {
    let message: AppUserMessage

    public init(message: AppUserMessage) {
        self.message = message
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.title)
                .font(.subheadline.weight(.semibold))
            Text(message.message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var backgroundColor: Color {
        switch message.kind {
        case .info:
            return Color.accentColor.opacity(0.12)
        case .error:
            return Color.red.opacity(0.12)
        }
    }
}

public struct AppOverviewSection: View {
    let overview: ExportOverview

    public init(overview: ExportOverview) {
        self.overview = overview
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            LabeledContent("Schema", value: overview.schemaVersion)
            LabeledContent("Exported At", value: overview.exportedAt)
            LabeledContent("Input Format", value: overview.inputFormat ?? "n/a")
            LabeledContent("Split Mode", value: overview.splitMode ?? "n/a")
            LabeledContent("Days", value: "\(overview.dayCount)")
            LabeledContent("Visits", value: "\(overview.totalVisitCount)")
            LabeledContent("Activities", value: "\(overview.totalActivityCount)")
            LabeledContent("Paths", value: "\(overview.totalPathCount)")

            if !overview.statsActivityTypes.isEmpty {
                LabeledContent("Stats Activity Types", value: overview.statsActivityTypes.joined(separator: ", "))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public struct AppDayListView: View {
    let summaries: [DaySummary]
    @Binding var selectedDate: String?

    public init(summaries: [DaySummary], selectedDate: Binding<String?>) {
        self.summaries = summaries
        self._selectedDate = selectedDate
    }

    public var body: some View {
        if summaries.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                Text("No Days Available")
                    .font(.headline)
                Text("This app export does not contain any day entries to inspect.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        } else {
            List(summaries, id: \.date, selection: $selectedDate) { summary in
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.date)
                        .font(.headline)
                    Text("\(summary.visitCount) visits, \(summary.activityCount) activities, \(summary.pathCount) paths")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if summary.pathCount > 0 {
                        Text("\(summary.totalPathPointCount) path points")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .tag(summary.date)
            }
        }
    }
}

public struct AppDayDetailView: View {
    let detail: DayDetailViewState?
    let hasDays: Bool

    public init(detail: DayDetailViewState?, hasDays: Bool) {
        self.detail = detail
        self.hasDays = hasDays
    }

    public var body: some View {
        if let detail {
            if detail.hasContent {
                VStack(alignment: .leading, spacing: 20) {
                    Text(detail.date)
                        .font(.title2)
                        .fontWeight(.semibold)

                    section("Visits", count: detail.visits.count) {
                        ForEach(Array(detail.visits.enumerated()), id: \.offset) { _, visit in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.semanticType ?? "Visit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(visit.startTime ?? "n/a") -> \(visit.endTime ?? "n/a")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let placeID = visit.placeID {
                                    Text(placeID)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    section("Activities", count: detail.activities.count) {
                        ForEach(Array(detail.activities.enumerated()), id: \.offset) { _, activity in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.activityType ?? "Activity")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(activity.startTime ?? "n/a") -> \(activity.endTime ?? "n/a")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let distanceM = activity.distanceM {
                                    Text(String(format: "%.0f m", distanceM))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    section("Paths", count: detail.paths.count) {
                        ForEach(Array(detail.paths.enumerated()), id: \.offset) { _, path in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(path.activityType ?? "Path")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(path.pointCount) points")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let distanceM = path.distanceM {
                                    Text(String(format: "%.0f m", distanceM))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                emptyState(
                    title: "No Content For This Day",
                    message: "This day exists in the app export, but it does not contain visits, activities or paths."
                )
            }
        } else if hasDays {
            emptyState(
                title: "No Day Selected",
                message: "Choose a day from the list to inspect visits, activities and paths."
            )
        } else {
            emptyState(
                title: "No Day Details Available",
                message: "Load a source with day entries to inspect visits, activities and paths."
            )
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, count: Int, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
    }

    @ViewBuilder
    private func emptyState(title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 240)
    }
}
#endif
