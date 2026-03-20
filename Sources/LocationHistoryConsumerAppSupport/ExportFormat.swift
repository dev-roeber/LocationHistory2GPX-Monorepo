import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public enum ExportFormat: String, Identifiable, CaseIterable {
    case gpx = "GPX"
    case kml = "KML"

    public static let allCases: [ExportFormat] = [.gpx, .kml]

    public var id: String { rawValue }

    public var fileExtension: String {
        switch self {
        case .gpx:
            return "gpx"
        case .kml:
            return "kml"
        }
    }

    public var description: String {
        switch self {
        case .gpx:
            return "GPS Exchange Format – compatible with most navigation and mapping apps."
        case .kml:
            return "Keyhole Markup Language – useful for Google Earth and other map viewers."
        }
    }

    public var systemImage: String {
        switch self {
        case .gpx:
            return "location.north.line.fill"
        case .kml:
            return "map.fill"
        }
    }

    #if canImport(UniformTypeIdentifiers)
    public var contentType: UTType {
        switch self {
        case .gpx:
            return .gpx
        case .kml:
            return .kml
        }
    }
    #endif
}
