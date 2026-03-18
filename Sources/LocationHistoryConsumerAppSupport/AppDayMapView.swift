#if canImport(SwiftUI) && canImport(MapKit)
import SwiftUI
import MapKit
import LocationHistoryConsumer

@available(iOS 17.0, macOS 14.0, *)
public struct AppDayMapView: View {
    let mapData: DayMapData
    @State private var useHybrid = false

    public init(mapData: DayMapData) {
        self.mapData = mapData
    }

    public var body: some View {
        if mapData.hasMapContent, let region = mapData.fittedRegion {
            mapContent(region: region)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Button {
                        useHybrid.toggle()
                    } label: {
                        Image(systemName: useHybrid ? "map" : "globe")
                            .font(.caption)
                            .padding(7)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .padding(8)
                    .accessibilityLabel(useHybrid ? "Switch to standard map" : "Switch to satellite map")
                }
                .accessibilityLabel(mapAccessibilityLabel)
        }
    }

    private var mapAccessibilityLabel: String {
        let visits = mapData.visitAnnotations.count
        let paths = mapData.pathOverlays.count
        switch (visits, paths) {
        case (0, 0): return "Map"
        case (_, 0): return "Map with \(visits) \(visits == 1 ? "visit" : "visits")"
        case (0, _): return "Map with \(paths) \(paths == 1 ? "path" : "paths")"
        default: return "Map with \(visits) \(visits == 1 ? "visit" : "visits") and \(paths) \(paths == 1 ? "path" : "paths")"
        }
    }

    @ViewBuilder
    private func mapContent(region: DayMapRegion) -> some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: region.centerLat,
                longitude: region.centerLon
            ),
            span: MKCoordinateSpan(
                latitudeDelta: region.spanLat,
                longitudeDelta: region.spanLon
            )
        ))) {
            ForEach(Array(mapData.pathOverlays.enumerated()), id: \.offset) { _, path in
                MapPolyline(coordinates: path.coordinates.map {
                    CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
                })
                .stroke(polylineColor(for: path.activityType), lineWidth: 3)
            }

            ForEach(Array(mapData.visitAnnotations.enumerated()), id: \.offset) { _, visit in
                Marker(
                    visit.semanticType ?? "Visit",
                    coordinate: CLLocationCoordinate2D(
                        latitude: visit.coordinate.lat,
                        longitude: visit.coordinate.lon
                    )
                )
                .tint(visitMarkerColor(for: visit.semanticType))
            }
        }
        .mapStyle(useHybrid ? .hybrid : .standard)
    }

    private func visitMarkerColor(for semanticType: String?) -> Color {
        switch (semanticType ?? "").uppercased() {
        case "HOME": return .blue
        case "WORK": return .indigo
        case "CAFE", "RESTAURANT", "FOOD": return .orange
        case "PARK", "NATURE", "GARDEN": return .green
        case "LEISURE", "GYM", "SPORT", "FITNESS": return .teal
        case "EVENT", "CONCERT": return .yellow
        case "STAY", "HOTEL", "ACCOMMODATION": return .mint
        default: return .red
        }
    }

    private func polylineColor(for activityType: String?) -> Color {
        switch (activityType ?? "").uppercased() {
        case "WALKING": return .green
        case "CYCLING": return .teal
        case "RUNNING": return .red
        case "IN PASSENGER VEHICLE": return .gray
        case "IN BUS": return .orange
        case "IN TRAIN": return .purple
        case "IN SUBWAY": return .purple
        case "FLYING": return .blue
        default: return .blue
        }
    }
}
#endif
