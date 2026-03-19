import XCTest
import LocationHistoryConsumer
@testable import LocationHistoryConsumerAppSupport

final class ExportPresentationTests: XCTestCase {
    func testReadinessHandlesEmptySelection() {
        let readiness = ExportPresentation.readiness(selection: ExportSelectionState(), summaries: [])
        XCTAssertEqual(readiness, .nothingSelected)
        XCTAssertEqual(
            ExportPresentation.helperMessage(selection: ExportSelectionState(), summaries: [], format: .gpx),
            "Choose at least one day with routes to prepare a GPX file."
        )
    }

    func testReadinessDetectsSelectedDaysWithoutRoutes() {
        var selection = ExportSelectionState()
        selection.toggle("2024-05-01")
        let summaries = makeSummaries(daysJSON: """
        {
          "date":"2024-05-01",
          "visits":[{"lat":48.0,"lon":11.0,"start_time":"2024-05-01T08:00:00Z","end_time":"2024-05-01T08:30:00Z"}],
          "activities":[],
          "paths":[]
        }
        """)

        XCTAssertEqual(
            ExportPresentation.readiness(selection: selection, summaries: summaries),
            .noRoutesSelected(selectedDayCount: 1)
        )
        XCTAssertEqual(
            ExportPresentation.buttonTitle(selection: selection, summaries: summaries, format: .gpx),
            "Selected day has no routes"
        )
    }

    func testReadinessSummarizesMixedSelection() {
        var selection = ExportSelectionState()
        selection.toggle("2024-05-01")
        selection.toggle("2024-05-02")
        let summaries = makeSummaries(daysJSON: """
        {
          "date":"2024-05-01",
          "visits":[{"lat":48.0,"lon":11.0,"start_time":"2024-05-01T08:00:00Z","end_time":"2024-05-01T08:30:00Z"}],
          "activities":[],
          "paths":[
            {"activity_type":"WALKING","distance_m":700,"points":[{"lat":48.0,"lon":11.0},{"lat":48.001,"lon":11.001}]},
            {"activity_type":"WALKING","distance_m":500,"points":[{"lat":48.002,"lon":11.002},{"lat":48.003,"lon":11.003}]}
          ]
        },
        {
          "date":"2024-05-02",
          "visits":[],
          "activities":[],
          "paths":[]
        }
        """)

        XCTAssertEqual(
            ExportPresentation.readiness(selection: selection, summaries: summaries),
            .ready(selectedDayCount: 2, exportableDayCount: 1, routeCount: 2)
        )
        XCTAssertTrue(
            ExportPresentation.helperMessage(selection: selection, summaries: summaries, format: .gpx)
                .contains("1 of 2 selected days contribute 2 routes")
        )
        XCTAssertEqual(
            ExportPresentation.filenameMessage(selection: selection, format: .gpx),
            "Suggested filename: lh2gpx-2024-05-01_to_2024-05-02.gpx (GPX)."
        )
    }

    private func makeSummaries(daysJSON: String) -> [DaySummary] {
        let json = """
        {
          "schema_version":"1.0",
          "meta":{
            "exported_at":"2024-01-01T00:00:00Z",
            "tool_version":"1.0",
            "source":{},
            "output":{},
            "config":{},
            "filters":{}
          },
          "data":{"days":[\(daysJSON)]}
        }
        """

        let export = try! AppExportDecoder.decode(data: Data(json.utf8))
        return AppExportQueries.daySummaries(from: export)
    }
}
