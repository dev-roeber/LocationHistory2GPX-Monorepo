import Foundation

public struct ExportWaypoint: Equatable {
    public let name: String
    public let category: String
    public let detail: String?
    public let latitude: Double
    public let longitude: Double
    public let time: String?

    public init(
        name: String,
        category: String,
        detail: String?,
        latitude: Double,
        longitude: Double,
        time: String?
    ) {
        self.name = name
        self.category = category
        self.detail = detail
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
}

public enum ExportWaypointExtractor {
    public static func waypoints(from days: [Day]) -> [ExportWaypoint] {
        days.flatMap(waypoints(in:))
    }

    public static func count(in day: Day) -> Int {
        waypoints(in: day).count
    }

    private static func waypoints(in day: Day) -> [ExportWaypoint] {
        var result: [ExportWaypoint] = []
        result.reserveCapacity(day.visits.count + (day.activities.count * 2))

        for (index, visit) in day.visits.enumerated() {
            guard let lat = visit.lat, let lon = visit.lon else {
                continue
            }

            let semanticType = normalizedLabel(visit.semanticType, fallback: "Visit")
            let suffix = day.visits.count > 1 ? " \(index + 1)" : ""
            result.append(
                ExportWaypoint(
                    name: "\(day.date) \(semanticType)\(suffix)",
                    category: "VISIT",
                    detail: visit.placeID ?? visit.semanticType,
                    latitude: lat,
                    longitude: lon,
                    time: visit.startTime ?? visit.endTime
                )
            )
        }

        for (index, activity) in day.activities.enumerated() {
            let activityType = normalizedLabel(activity.activityType, fallback: "Activity")
            let suffix = day.activities.count > 1 ? " \(index + 1)" : ""

            if let startLat = activity.startLat, let startLon = activity.startLon {
                result.append(
                    ExportWaypoint(
                        name: "\(day.date) \(activityType) Start\(suffix)",
                        category: "ACTIVITY_START",
                        detail: activity.activityType,
                        latitude: startLat,
                        longitude: startLon,
                        time: activity.startTime
                    )
                )
            }

            if let endLat = activity.endLat, let endLon = activity.endLon {
                result.append(
                    ExportWaypoint(
                        name: "\(day.date) \(activityType) End\(suffix)",
                        category: "ACTIVITY_END",
                        detail: activity.activityType,
                        latitude: endLat,
                        longitude: endLon,
                        time: activity.endTime
                    )
                )
            }
        }

        return result
    }

    private static func normalizedLabel(_ value: String?, fallback: String) -> String {
        guard let value, !value.isEmpty else {
            return fallback
        }
        return value.capitalized
    }
}
