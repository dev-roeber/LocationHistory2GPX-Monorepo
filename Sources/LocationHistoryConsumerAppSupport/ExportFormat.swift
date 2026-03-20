import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public enum ExportFormat: String, Identifiable, CaseIterable {
    case gpx = "GPX"
    case kml = "KML"
    case geoJSON = "GeoJSON"

    public static let allCases: [ExportFormat] = [.gpx, .kml, .geoJSON]

    public var id: String { rawValue }

    public var fileExtension: String {
        switch self {
        case .gpx:
            return "gpx"
        case .kml:
            return "kml"
        case .geoJSON:
            return "geojson"
        }
    }

    public var description: String {
        switch self {
        case .gpx:
            return "GPS Exchange Format – compatible with most navigation and mapping apps."
        case .kml:
            return "Keyhole Markup Language – useful for Google Earth and other map viewers."
        case .geoJSON:
            return "GeoJSON FeatureCollection – useful for browsers, GIS tools, and developer workflows."
        }
    }

    public var systemImage: String {
        switch self {
        case .gpx:
            return "location.north.line.fill"
        case .kml:
            return "map.fill"
        case .geoJSON:
            return "curlybraces"
        }
    }

    #if canImport(UniformTypeIdentifiers)
    public var contentType: UTType {
        switch self {
        case .gpx:
            return .gpx
        case .kml:
            return .kml
        case .geoJSON:
            return .geoJSON
        }
    }
    #endif
}
