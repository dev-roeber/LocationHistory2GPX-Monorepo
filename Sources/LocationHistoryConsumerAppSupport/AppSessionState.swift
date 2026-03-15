import Foundation
import LocationHistoryConsumer

public enum AppContentSource: Equatable {
    case demoFixture(name: String)
    case importedFile(filename: String)

    public var displayName: String {
        switch self {
        case let .demoFixture(name):
            return "\(name).json"
        case let .importedFile(filename):
            return filename
        }
    }
}

public struct AppSessionContent {
    public let export: AppExport
    public let overview: ExportOverview
    public let daySummaries: [DaySummary]
    public let selectedDate: String?
    public let source: AppContentSource

    public init(export: AppExport, source: AppContentSource) {
        self.export = export
        self.overview = AppExportQueries.overview(from: export)
        self.daySummaries = AppExportQueries.daySummaries(from: export)
        self.selectedDate = self.daySummaries.first?.date
        self.source = source
    }

    public func detail(for date: String?) -> DayDetailViewState? {
        guard let date else {
            return nil
        }
        return AppExportQueries.dayDetail(for: date, in: export)
    }
}

public enum AppMessageKind: Equatable {
    case info
    case error
}

public struct AppUserMessage: Equatable {
    public let kind: AppMessageKind
    public let title: String
    public let message: String

    public init(kind: AppMessageKind, title: String, message: String) {
        self.kind = kind
        self.title = title
        self.message = message
    }
}

public struct AppSessionState {
    public private(set) var isLoading: Bool
    public private(set) var content: AppSessionContent?
    public private(set) var selectedDate: String?
    public private(set) var message: AppUserMessage?

    public init(
        isLoading: Bool = false,
        content: AppSessionContent? = nil,
        selectedDate: String? = nil,
        message: AppUserMessage? = nil
    ) {
        self.isLoading = isLoading
        self.content = content
        self.selectedDate = selectedDate
        self.message = message
    }

    public var overview: ExportOverview? {
        content?.overview
    }

    public var daySummaries: [DaySummary] {
        content?.daySummaries ?? []
    }

    public var selectedDetail: DayDetailViewState? {
        content?.detail(for: selectedDate)
    }

    public var source: AppContentSource? {
        content?.source
    }

    public var sourceDescription: String? {
        guard let source else {
            return nil
        }
        switch source {
        case let .demoFixture(name):
            return "Demo fixture: \(name).json"
        case let .importedFile(filename):
            return "Imported file: \(filename)"
        }
    }

    public var hasLoadedContent: Bool {
        content != nil
    }

    public var hasDays: Bool {
        !daySummaries.isEmpty
    }

    public mutating func beginLoading() {
        isLoading = true
        message = nil
    }

    public mutating func show(content: AppSessionContent) {
        self.content = content
        selectedDate = content.selectedDate
        isLoading = false
        message = AppUserMessage(
            kind: .info,
            title: content.source == .demoFixture(name: AppContentLoader.defaultDemoFixtureName) ? "Demo data ready" : "Imported app export ready",
            message: sourceDescription ?? content.source.displayName
        )
    }

    public mutating func selectDay(_ date: String?) {
        guard let date else {
            selectedDate = nil
            return
        }

        if daySummaries.contains(where: { $0.date == date }) {
            selectedDate = date
        } else {
            selectedDate = daySummaries.first?.date
        }
    }

    public mutating func showFailure(title: String, message: String, preserveCurrentContent: Bool) {
        isLoading = false
        self.message = AppUserMessage(kind: .error, title: title, message: message)
        if !preserveCurrentContent {
            content = nil
            selectedDate = nil
        }
    }
}
