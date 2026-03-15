#if canImport(SwiftUI)
import SwiftUI
import LocationHistoryConsumer

struct OverviewSection: View {
    let overview: ExportOverview

    var body: some View {
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
#endif
