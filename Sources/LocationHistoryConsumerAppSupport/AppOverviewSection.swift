#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer

// MARK: - Overview Section

public struct AppOverviewSection: View {
    let overview: ExportOverview
    var onDaysTap: (() -> Void)? = nil
    var onInsightsTap: (() -> Void)? = nil

    public init(overview: ExportOverview, onDaysTap: (() -> Void)? = nil, onInsightsTap: (() -> Void)? = nil) {
        self.overview = overview
        self.onDaysTap = onDaysTap
        self.onInsightsTap = onInsightsTap
    }

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 160), spacing: 12)
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title3.weight(.semibold))

            LazyVGrid(columns: columns, spacing: 12) {
                statCard("\(overview.dayCount)", label: "Days", icon: "calendar", color: .blue, action: onDaysTap)
                statCard("\(overview.totalVisitCount)", label: "Visits", icon: "mappin.and.ellipse", color: .purple, action: onInsightsTap)
                statCard("\(overview.totalActivityCount)", label: "Activities", icon: "figure.walk", color: .green, action: onInsightsTap)
                statCard("\(overview.totalPathCount)", label: "Routes", icon: "location.north.line", color: .orange, action: onInsightsTap)
            }
        }
    }

    @ViewBuilder
    private func statCard(_ value: String, label: String, icon: String, color: Color, action: (() -> Void)? = nil) -> some View {
        Group {
            if let action {
                Button(action: action) {
                    statCardBody(value, label: label, icon: icon, color: color, isInteractive: true)
                }
                .buttonStyle(.plain)
            } else {
                statCardBody(value, label: label, icon: icon, color: color, isInteractive: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(label)")
        .accessibilityAddTraits(action != nil ? .isButton : [])
    }

    @ViewBuilder
    private func statCardBody(_ value: String, label: String, icon: String, color: Color, isInteractive: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            if isInteractive {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(color.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#endif
