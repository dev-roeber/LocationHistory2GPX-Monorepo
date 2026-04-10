import Foundation

// MARK: - Unit

public enum RecordingIntervalUnit: String, Codable, CaseIterable, Identifiable, Sendable {
    case seconds
    case minutes
    case hours

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .seconds: return "Seconds"
        case .minutes: return "Minutes"
        case .hours: return "Hours"
        }
    }

    /// Singular display name used when value == 1 (e.g. "Second", "Minute", "Hour").
    public var singularDisplayName: String {
        switch self {
        case .seconds: return "Second"
        case .minutes: return "Minute"
        case .hours:   return "Hour"
        }
    }

    /// Lowercase singular key for localisation lookups (e.g. "second", "minute", "hour").
    public var singularKey: String {
        switch self {
        case .seconds: return "second"
        case .minutes: return "minute"
        case .hours:   return "hour"
        }
    }

}

// MARK: - Preference

public struct RecordingIntervalPreference: Codable, Equatable, Sendable {
    public let unit: RecordingIntervalUnit
    public let value: Int

    public static let minimumValue = 0
    public static let unlimitedDisplayString = "Unlimited"

    /// 5 seconds – matches the rough cadence of a balanced live recording session.
    public static let `default` = RecordingIntervalPreference(value: 5, unit: .seconds)

    public init(value: Int, unit: RecordingIntervalUnit) {
        self.value = value
        self.unit = unit
    }

    /// Returns a valid instance. Values below 0 are clipped to 0 (`No minimum`).
    /// There is intentionally no upper clamp: the UI treats the maximum gap as unlimited.
    public static func validated(value: Int, unit: RecordingIntervalUnit) -> RecordingIntervalPreference {
        RecordingIntervalPreference(value: max(minimumValue, value), unit: unit)
    }

    public var hasNoMinimum: Bool {
        value == Self.minimumValue
    }

    /// Total interval expressed in seconds.
    public var totalSeconds: TimeInterval {
        guard value > 0 else { return 0 }
        switch unit {
        case .seconds: return TimeInterval(value)
        case .minutes: return TimeInterval(value) * 60
        case .hours:   return TimeInterval(value) * 3600
        }
    }

    /// Plain English display string for the interval, e.g. "5 seconds", "1 minute".
    /// For a localised variant, build the string from `value` and a localised `unit.singularKey`/`unit.rawValue`.
    public var displayString: String {
        guard !hasNoMinimum else {
            return "No minimum"
        }
        switch unit {
        case .seconds: return value == 1 ? "1 second"  : "\(value) seconds"
        case .minutes: return value == 1 ? "1 minute"  : "\(value) minutes"
        case .hours:   return value == 1 ? "1 hour"    : "\(value) hours"
        }
    }
}
