import Foundation
import LocationHistoryConsumer

enum ExportReadiness: Equatable {
    case nothingSelected
    case noExportableContent(selectedSourceCount: Int)
    case ready(
        selectedSourceCount: Int,
        exportableSourceCount: Int,
        routeCount: Int,
        waypointCount: Int,
        selectedDayCount: Int,
        selectedRecordedTrackCount: Int
    )
}

enum ExportPresentation {
    static func readiness(
        importedExport: AppExport?,
        selection: ExportSelectionState,
        recordedTracks: [RecordedTrack]
        ,
        queryFilter: AppExportQueryFilter? = nil,
        mode: ExportMode
    ) -> ExportReadiness {
        let snapshot = ExportSelectionContent.snapshot(
            importedExport: importedExport,
            selection: selection,
            recordedTracks: recordedTracks,
            queryFilter: queryFilter,
            mode: mode
        )

        guard snapshot.selectedSourceCount > 0 else {
            return .nothingSelected
        }

        guard snapshot.contentCount > 0 else {
            return .noExportableContent(selectedSourceCount: snapshot.selectedSourceCount)
        }

        return .ready(
            selectedSourceCount: snapshot.selectedSourceCount,
            exportableSourceCount: snapshot.exportableSourceCount,
            routeCount: snapshot.routeCount,
            waypointCount: snapshot.waypointCount,
            selectedDayCount: snapshot.selectedDayCount,
            selectedRecordedTrackCount: snapshot.selectedRecordedTrackCount
        )
    }

    static func buttonTitle(
        importedExport: AppExport?,
        selection: ExportSelectionState,
        recordedTracks: [RecordedTrack],
        format: ExportFormat,
        queryFilter: AppExportQueryFilter? = nil,
        mode: ExportMode
    ) -> String {
        switch readiness(
            importedExport: importedExport,
            selection: selection,
            recordedTracks: recordedTracks,
            queryFilter: queryFilter,
            mode: mode
        ) {
        case .nothingSelected:
            return "Select history or tracks to export"
        case let .noExportableContent(selectedSourceCount):
            switch mode {
            case .tracks:
                return selectedSourceCount == 1 ? "Selected item has no routes" : "Selected items have no routes"
            case .waypoints:
                return selectedSourceCount == 1 ? "Selected item has no waypoints" : "Selected items have no waypoints"
            case .both:
                return selectedSourceCount == 1 ? "Selected item has no exportable map content" : "Selected items have no exportable map content"
            }
        case let .ready(selectedSourceCount, _, _, _, _, _):
            return "Export \(selectedSourceCount) \(selectedSourceCount == 1 ? "item" : "items") as \(format.rawValue)"
        }
    }

    static func helperMessage(
        importedExport: AppExport?,
        selection: ExportSelectionState,
        recordedTracks: [RecordedTrack],
        format: ExportFormat,
        queryFilter: AppExportQueryFilter? = nil,
        mode: ExportMode
    ) -> String {
        switch readiness(
            importedExport: importedExport,
            selection: selection,
            recordedTracks: recordedTracks,
            queryFilter: queryFilter,
            mode: mode
        ) {
        case .nothingSelected:
            switch mode {
            case .tracks:
                return "Choose at least one imported day or saved track with routes to prepare a \(format.rawValue) file."
            case .waypoints:
                return "Choose at least one imported day with visits or activity endpoints to prepare a \(format.rawValue) file."
            case .both:
                return "Choose imported history or saved tracks with routes or waypoint locations to prepare a \(format.rawValue) file."
            }
        case let .noExportableContent(selectedSourceCount):
            switch mode {
            case .tracks:
                return selectedSourceCount == 1
                    ? "The selected item contains no route with usable GPS points."
                    : "None of the selected items contain routes with usable GPS points."
            case .waypoints:
                return selectedSourceCount == 1
                    ? "The selected item contains no visit or activity endpoint with usable coordinates."
                    : "None of the selected items contain visit or activity endpoints with usable coordinates."
            case .both:
                return selectedSourceCount == 1
                    ? "The selected item contains neither route geometry nor waypoint locations."
                    : "None of the selected items contain route geometry or waypoint locations."
            }
        case let .ready(selectedSourceCount, exportableSourceCount, routeCount, waypointCount, _, _):
            let contentSummary = exportedContentSummary(routeCount: routeCount, waypointCount: waypointCount)
            if exportableSourceCount < selectedSourceCount {
                return "\(exportableSourceCount) of \(selectedSourceCount) selected items contribute \(contentSummary). Sources without matching content stay out of the \(format.rawValue) file."
            }
            return "\(contentSummary) will be written to the \(format.rawValue) file."
        }
    }

    static func suggestedFilename(
        selection: ExportSelectionState,
        summaries: [DaySummary],
        recordedTracks: [RecordedTrack],
        format: ExportFormat,
        mode: ExportMode
    ) -> String {
        let sortedDates = ExportSelectionContent.filenameDates(
            selection: selection,
            summaries: summaries,
            recordedTracks: recordedTracks
        )
        let modeSuffix: String
        switch mode {
        case .tracks:
            modeSuffix = ""
        case .waypoints:
            modeSuffix = "-waypoints"
        case .both:
            modeSuffix = "-mixed"
        }
        switch sortedDates.count {
        case 0:
            return "lh2gpx-export\(modeSuffix).\(format.fileExtension)"
        case 1:
            return "lh2gpx-\(sortedDates[0])\(modeSuffix).\(format.fileExtension)"
        default:
            guard let first = sortedDates.first, let last = sortedDates.last else {
                return "lh2gpx-export\(modeSuffix).\(format.fileExtension)"
            }
            return "lh2gpx-\(first)_to_\(last)\(modeSuffix).\(format.fileExtension)"
        }
    }

    static func filenameMessage(
        selection: ExportSelectionState,
        summaries: [DaySummary],
        recordedTracks: [RecordedTrack],
        format: ExportFormat,
        mode: ExportMode
    ) -> String {
        let filename = suggestedFilename(
            selection: selection,
            summaries: summaries,
            recordedTracks: recordedTracks,
            format: format,
            mode: mode
        )
        return "Suggested filename: \(filename) (\(format.fileExtension.uppercased()))."
    }

    private static func exportedContentSummary(routeCount: Int, waypointCount: Int) -> String {
        var parts: [String] = []
        if routeCount > 0 {
            parts.append("\(routeCount) route\(routeCount == 1 ? "" : "s")")
        }
        if waypointCount > 0 {
            parts.append("\(waypointCount) waypoint\(waypointCount == 1 ? "" : "s")")
        }
        return parts.joined(separator: " and ")
    }
}
