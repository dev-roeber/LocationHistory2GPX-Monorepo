import Foundation

public enum GeoJSONBuilder {
    public static func build(from days: [Day], mode: ExportMode = .tracks) -> String {
        var features: [[String: Any]] = []

        if mode.includesTracks {
            for day in days {
                for (pathIndex, path) in day.paths.enumerated() where !path.points.isEmpty {
                    let coordinates = path.points.map { [$0.lon, $0.lat] }
                    let geometry: [String: Any] = [
                        "type": "LineString",
                        "coordinates": coordinates
                    ]
                    var properties: [String: Any] = [
                        "name": trackTitle(date: day.date, activityType: path.activityType, index: pathIndex),
                        "geometry_kind": "track"
                    ]
                    if let activityType = path.activityType, !activityType.isEmpty {
                        properties["activity_type"] = activityType
                    }
                    if let distanceM = path.distanceM {
                        properties["distance_m"] = distanceM
                    }

                    features.append([
                        "type": "Feature",
                        "geometry": geometry,
                        "properties": properties
                    ])
                }
            }
        }

        if mode.includesWaypoints {
            for waypoint in ExportWaypointExtractor.waypoints(from: days) {
                var properties: [String: Any] = [
                    "name": waypoint.name,
                    "category": waypoint.category,
                    "geometry_kind": "waypoint"
                ]
                if let detail = waypoint.detail, !detail.isEmpty {
                    properties["detail"] = detail
                }
                if let time = waypoint.time, !time.isEmpty {
                    properties["time"] = time
                }

                features.append([
                    "type": "Feature",
                    "geometry": [
                        "type": "Point",
                        "coordinates": [waypoint.longitude, waypoint.latitude]
                    ],
                    "properties": properties
                ])
            }
        }

        let root: [String: Any] = [
            "type": "FeatureCollection",
            "features": features
        ]

        guard JSONSerialization.isValidJSONObject(root),
              let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return "{\n  \"type\" : \"FeatureCollection\",\n  \"features\" : [ ]\n}"
        }

        return text
    }

    private static func trackTitle(date: String, activityType: String?, index: Int) -> String {
        let typePart = activityType.map { " – \($0.capitalized)" } ?? ""
        let indexSuffix = index > 0 ? " (\(index + 1))" : ""
        return "\(date)\(typePart)\(indexSuffix)"
    }
}
