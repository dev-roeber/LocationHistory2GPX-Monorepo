import Foundation
import LocationHistoryConsumer

// MARK: - Route Grid Builder (Foundation-only core, no SwiftUI/MapKit needed)

enum RouteGridBuilder {
    struct SegBin: Hashable {
        let lat: Int32
        let lon: Int32
    }

    nonisolated static func computeGrid(
        for export: AppExport,
        step: Double
    ) -> [SegBin: Int] {
        var counts: [SegBin: Int] = [:]

        func addSegments(from coords: [Double]) {
            guard coords.count >= 4 else { return }
            var i = 0
            while i + 3 < coords.count {
                let lat1 = coords[i]; let lon1 = coords[i + 1]
                let lat2 = coords[i + 2]; let lon2 = coords[i + 3]
                let midLat = (lat1 + lat2) / 2.0
                let midLon = (lon1 + lon2) / 2.0
                let bin = SegBin(
                    lat: Int32(floor(midLat / step)),
                    lon: Int32(floor(midLon / step))
                )
                counts[bin, default: 0] += 1
                i += 2
            }
        }

        func addPathPoints(_ pts: [PathPoint]) {
            guard pts.count >= 2 else { return }
            for i in 0..<(pts.count - 1) {
                let midLat = (pts[i].lat + pts[i + 1].lat) / 2.0
                let midLon = (pts[i].lon + pts[i + 1].lon) / 2.0
                let bin = SegBin(
                    lat: Int32(floor(midLat / step)),
                    lon: Int32(floor(midLon / step))
                )
                counts[bin, default: 0] += 1
            }
        }

        for day in export.data.days {
            for path in day.paths {
                if let flats = path.flatCoordinates {
                    addSegments(from: flats)
                } else if !path.points.isEmpty {
                    addPathPoints(path.points)
                }
            }
            for activity in day.activities {
                if let flats = activity.flatCoordinates {
                    addSegments(from: flats)
                } else if let sLat = activity.startLat, let sLon = activity.startLon,
                          let eLat = activity.endLat, let eLon = activity.endLon {
                    let midLat = (sLat + eLat) / 2.0
                    let midLon = (sLon + eLon) / 2.0
                    let bin = SegBin(
                        lat: Int32(floor(midLat / step)),
                        lon: Int32(floor(midLon / step))
                    )
                    counts[bin, default: 0] += 1
                }
            }
        }

        return counts
    }
}
