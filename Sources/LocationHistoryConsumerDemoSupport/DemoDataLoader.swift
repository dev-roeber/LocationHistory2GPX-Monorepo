import Foundation
import LocationHistoryConsumer

public struct DemoContent {
    public let export: AppExport
    public let overview: ExportOverview
    public let daySummaries: [DaySummary]
    public let selectedDate: String?

    public init(export: AppExport) {
        self.export = export
        self.overview = AppExportQueries.overview(from: export)
        self.daySummaries = AppExportQueries.daySummaries(from: export)
        self.selectedDate = self.daySummaries.first?.date
    }

    public func detail(for date: String?) -> DayDetailViewState? {
        guard let date else {
            return nil
        }
        return AppExportQueries.dayDetail(for: date, in: export)
    }
}

public enum DemoDataLoaderError: LocalizedError {
    case fixtureNotFound(String)

    public var errorDescription: String? {
        switch self {
        case let .fixtureNotFound(name):
            return "Demo fixture not found: \(name).json"
        }
    }
}

public enum DemoDataLoader {
    public static let defaultFixtureName = "golden_app_export_sample_small"

    public static func loadDefaultContent() throws -> DemoContent {
        try loadContent(named: defaultFixtureName)
    }

    public static func loadContent(named name: String) throws -> DemoContent {
        let url = try fixtureURL(named: name)
        let export = try AppExportDecoder.decode(contentsOf: url)
        return DemoContent(export: export)
    }

    public static func fixtureURL(named name: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw DemoDataLoaderError.fixtureNotFound(name)
        }
        return url
    }
}
