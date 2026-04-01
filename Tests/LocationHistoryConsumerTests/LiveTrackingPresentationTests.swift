import XCTest
@testable import LocationHistoryConsumerAppSupport

final class LiveTrackingPresentationTests: XCTestCase {
    func testMetricsCalculateDistanceSpeedAndLatestSampleDate() {
        let start = Date(timeIntervalSince1970: 1_710_000_000)
        let points = [
            RecordedTrackPoint(latitude: 52.52, longitude: 13.40, timestamp: start, horizontalAccuracyM: 6),
            RecordedTrackPoint(latitude: 52.5209, longitude: 13.4090, timestamp: start.addingTimeInterval(60), horizontalAccuracyM: 6),
        ]
        let currentLocation = LiveLocationSample(
            latitude: 52.5210,
            longitude: 13.4100,
            timestamp: start.addingTimeInterval(90),
            horizontalAccuracyM: 5
        )

        let snapshot = LiveTrackingPresentation.metrics(
            points: points,
            currentLocation: currentLocation
        )

        XCTAssertGreaterThan(snapshot.totalDistanceM, 600)
        XCTAssertNotNil(snapshot.currentSpeedKMH)
        XCTAssertNotNil(snapshot.lastSegmentDistanceM)
        XCTAssertEqual(snapshot.lastSampleDate, currentLocation.timestamp)
    }

    func testMetricsStayGracefulWithoutAcceptedPoints() {
        let snapshot = LiveTrackingPresentation.metrics(
            points: [],
            currentLocation: nil
        )

        XCTAssertEqual(snapshot.totalDistanceM, 0)
        XCTAssertNil(snapshot.currentSpeedKMH)
        XCTAssertNil(snapshot.lastSegmentDistanceM)
        XCTAssertNil(snapshot.lastSampleDate)
    }
}
