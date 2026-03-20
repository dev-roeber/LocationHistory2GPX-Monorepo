import Foundation

public enum ExportMode: String, Identifiable, CaseIterable {
    case tracks = "Tracks"
    case waypoints = "Waypoints"
    case both = "Both"

    public var id: String { rawValue }

    public var includesTracks: Bool {
        switch self {
        case .tracks, .both:
            return true
        case .waypoints:
            return false
        }
    }

    public var includesWaypoints: Bool {
        switch self {
        case .waypoints, .both:
            return true
        case .tracks:
            return false
        }
    }
}
