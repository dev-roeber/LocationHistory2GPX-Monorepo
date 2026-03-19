import Foundation
import LocationHistoryConsumer

enum ExportReadiness: Equatable {
    case nothingSelected
    case noRoutesSelected(selectedDayCount: Int)
    case ready(selectedDayCount: Int, exportableDayCount: Int, routeCount: Int)
}

enum ExportPresentation {
    static func readiness(selection: ExportSelectionState, summaries: [DaySummary]) -> ExportReadiness {
        let selected = selectedSummaries(selection: selection, summaries: summaries)
        guard !selected.isEmpty else {
            return .nothingSelected
        }

        let exportable = selected.filter { $0.pathCount > 0 }
        let routeCount = exportable.reduce(0) { $0 + $1.pathCount }
        guard !exportable.isEmpty else {
            return .noRoutesSelected(selectedDayCount: selected.count)
        }

        return .ready(
            selectedDayCount: selected.count,
            exportableDayCount: exportable.count,
            routeCount: routeCount
        )
    }

    static func buttonTitle(selection: ExportSelectionState, summaries: [DaySummary], format: ExportFormat) -> String {
        switch readiness(selection: selection, summaries: summaries) {
        case .nothingSelected:
            return "Select days to export"
        case let .noRoutesSelected(selectedDayCount):
            return selectedDayCount == 1
                ? "Selected day has no routes"
                : "Selected days have no routes"
        case let .ready(selectedDayCount, _, _):
            return "Export \(selectedDayCount) \(selectedDayCount == 1 ? "day" : "days") as \(format.rawValue)"
        }
    }

    static func helperMessage(selection: ExportSelectionState, summaries: [DaySummary], format: ExportFormat) -> String {
        switch readiness(selection: selection, summaries: summaries) {
        case .nothingSelected:
            return "Choose at least one day with routes to prepare a \(format.rawValue) file."
        case let .noRoutesSelected(selectedDayCount):
            return selectedDayCount == 1
                ? "The selected day contains no routes with GPS points."
                : "None of the selected days contain routes with GPS points."
        case let .ready(selectedDayCount, exportableDayCount, routeCount):
            if exportableDayCount < selectedDayCount {
                return "\(exportableDayCount) of \(selectedDayCount) selected days contribute \(routeCount) route\(routeCount == 1 ? "" : "s"). Days without routes stay out of the GPX content."
            }
            return "\(routeCount) route\(routeCount == 1 ? "" : "s") will be written to the \(format.rawValue) file."
        }
    }

    static func suggestedFilename(selection: ExportSelectionState) -> String {
        GPXBuilder.suggestedFilename(for: Array(selection.selectedDates))
    }

    static func filenameMessage(selection: ExportSelectionState, format: ExportFormat) -> String {
        let filename = suggestedFilename(selection: selection)
        return "Suggested filename: \(filename) (\(format.fileExtension.uppercased()))."
    }

    private static func selectedSummaries(selection: ExportSelectionState, summaries: [DaySummary]) -> [DaySummary] {
        summaries.filter { selection.isSelected($0.date) }
    }
}
