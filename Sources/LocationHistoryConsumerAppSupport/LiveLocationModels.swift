import Foundation

public enum LiveLocationAuthorization: Equatable {
    case notDetermined
    case restricted
    case denied
    case authorizedWhenInUse
    case authorizedAlways

    public var allowsForegroundTracking: Bool {
        switch self {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined, .restricted, .denied:
            return false
        }
    }
}

public struct LiveLocationSample: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let timestamp: Date
    public let horizontalAccuracyM: Double

    public init(
        latitude: Double,
        longitude: Double,
        timestamp: Date,
        horizontalAccuracyM: Double
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.horizontalAccuracyM = horizontalAccuracyM
    }
}

public struct RecordedTrackPoint: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    public let timestamp: Date
    public let horizontalAccuracyM: Double

    public init(
        latitude: Double,
        longitude: Double,
        timestamp: Date,
        horizontalAccuracyM: Double
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.horizontalAccuracyM = horizontalAccuracyM
    }
}

public enum RecordedTrackCaptureMode: String, Codable, Equatable {
    case foregroundWhileInUse
}

public struct RecordedTrack: Codable, Equatable, Identifiable {
    public let id: UUID
    public let startedAt: Date
    public let endedAt: Date
    public let dayKey: String
    public let distanceM: Double
    public let captureMode: RecordedTrackCaptureMode
    public let points: [RecordedTrackPoint]

    public init(
        id: UUID = UUID(),
        startedAt: Date,
        endedAt: Date,
        dayKey: String,
        distanceM: Double,
        captureMode: RecordedTrackCaptureMode,
        points: [RecordedTrackPoint]
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.dayKey = dayKey
        self.distanceM = distanceM
        self.captureMode = captureMode
        self.points = points
    }

    public var pointCount: Int {
        points.count
    }
}
