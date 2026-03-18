import Foundation
import Combine

public enum AppDistanceUnitPreference: String, CaseIterable, Identifiable {
    case metric
    case imperial

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .metric: return "Kilometers"
        case .imperial: return "Miles"
        }
    }

    public var shortLabel: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        }
    }
}

public enum AppStartTabPreference: String, CaseIterable, Identifiable {
    case overview
    case days
    case insights
    case export

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .overview: return "Overview"
        case .days: return "Days"
        case .insights: return "Insights"
        case .export: return "Export"
        }
    }

    var tabIndex: Int {
        switch self {
        case .overview: return 0
        case .days: return 1
        case .insights: return 2
        case .export: return 3
        }
    }
}

public enum AppMapStylePreference: String, CaseIterable, Identifiable {
    case standard
    case hybrid

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .standard: return "Standard"
        case .hybrid: return "Satellite Hybrid"
        }
    }

    public var isHybrid: Bool {
        self == .hybrid
    }

    mutating func toggle() {
        self = isHybrid ? .standard : .hybrid
    }
}

@MainActor
public final class AppPreferences: ObservableObject {
    private enum Keys {
        static let distanceUnit = "app.preferences.distanceUnit"
        static let startTab = "app.preferences.startTab"
        static let mapStyle = "app.preferences.mapStyle"
        static let showsTechnicalImportDetails = "app.preferences.showsTechnicalImportDetails"
    }

    private let userDefaults: UserDefaults

    @Published public var distanceUnit: AppDistanceUnitPreference {
        didSet { userDefaults.set(distanceUnit.rawValue, forKey: Keys.distanceUnit) }
    }

    @Published public var startTab: AppStartTabPreference {
        didSet { userDefaults.set(startTab.rawValue, forKey: Keys.startTab) }
    }

    @Published public var preferredMapStyle: AppMapStylePreference {
        didSet { userDefaults.set(preferredMapStyle.rawValue, forKey: Keys.mapStyle) }
    }

    @Published public var showsTechnicalImportDetails: Bool {
        didSet { userDefaults.set(showsTechnicalImportDetails, forKey: Keys.showsTechnicalImportDetails) }
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.distanceUnit = Self.loadEnum(
            AppDistanceUnitPreference.self,
            key: Keys.distanceUnit,
            from: userDefaults
        ) ?? .metric
        self.startTab = Self.loadEnum(
            AppStartTabPreference.self,
            key: Keys.startTab,
            from: userDefaults
        ) ?? .overview
        self.preferredMapStyle = Self.loadEnum(
            AppMapStylePreference.self,
            key: Keys.mapStyle,
            from: userDefaults
        ) ?? .standard
        self.showsTechnicalImportDetails = userDefaults.object(forKey: Keys.showsTechnicalImportDetails) as? Bool ?? true
    }

    public func reset() {
        userDefaults.removeObject(forKey: Keys.distanceUnit)
        userDefaults.removeObject(forKey: Keys.startTab)
        userDefaults.removeObject(forKey: Keys.mapStyle)
        userDefaults.removeObject(forKey: Keys.showsTechnicalImportDetails)

        distanceUnit = .metric
        startTab = .overview
        preferredMapStyle = .standard
        showsTechnicalImportDetails = true
    }

    private static func loadEnum<T: RawRepresentable>(
        _ type: T.Type,
        key: String,
        from userDefaults: UserDefaults
    ) -> T? where T.RawValue == String {
        guard let rawValue = userDefaults.string(forKey: key) else {
            return nil
        }
        return T(rawValue: rawValue)
    }
}
