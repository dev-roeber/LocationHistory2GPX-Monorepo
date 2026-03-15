#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer

struct DayListView: View {
    let summaries: [DaySummary]
    @Binding var selectedDate: String?

    var body: some View {
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
#endif
