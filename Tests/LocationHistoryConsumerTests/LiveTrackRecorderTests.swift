import XCTest
@testable import LocationHistoryConsumerAppSupport

final class LiveTrackRecorderTests: XCTestCase {
    func testRecorderStartsEmpty() {
        let recorder = LiveTrackRecorder()
        XCTAssertTrue(recorder.points.isEmpty)
        XCTAssertFalse(recorder.isRecording)
    }

    func testFirstAccuratePointIsAccepted() {
        var recorder = LiveTrackRecorder()
        recorder.start()

        let didAccept = recorder.append(sample(offsetSeconds: 0, latitude: 52.52, longitude: 13.40, accuracy: 8))

        XCTAssertTrue(didAccept)
        XCTAssertEqual(recorder.points.count, 1)
    }

    func testDuplicatePointIsRejected() {
        var recorder = LiveTrackRecorder()
        recorder.start()
        XCTAssertTrue(recorder.append(sample(offsetSeconds: 0, latitude: 52.52, longitude: 13.40, accuracy: 5)))

        let didAccept = recorder.append(sample(offsetSeconds: 12, latitude: 52.52, longitude: 13.40, accuracy: 5))

        XCTAssertFalse(didAccept)
        XCTAssertEqual(recorder.points.count, 1)
    }

    func testPoorAccuracyIsRejected() {
        var recorder = LiveTrackRecorder()
        recorder.start()

        let didAccept = recorder.append(sample(offsetSeconds: 0, latitude: 52.52, longitude: 13.40, accuracy: 150))

        XCTAssertFalse(didAccept)
        XCTAssertTrue(recorder.points.isEmpty)
    }

    func testStopClearsDraftAndRequiresNewStart() {
        var recorder = LiveTrackRecorder()
        recorder.start()
        XCTAssertTrue(recorder.append(sample(offsetSeconds: 0, latitude: 52.52, longitude: 13.40, accuracy: 5)))
        XCTAssertTrue(recorder.append(sample(offsetSeconds: 12, latitude: 52.5202, longitude: 13.4002, accuracy: 5)))

        let track = recorder.stop()
        let didAcceptAfterStop = recorder.append(sample(offsetSeconds: 24, latitude: 52.5204, longitude: 13.4004, accuracy: 5))

        XCTAssertNotNil(track)
        XCTAssertFalse(recorder.isRecording)
        XCTAssertTrue(recorder.points.isEmpty)
        XCTAssertFalse(didAcceptAfterStop)
    }

    private func sample(offsetSeconds: TimeInterval, latitude: Double, longitude: Double, accuracy: Double) -> LiveLocationSample {
        LiveLocationSample(
            latitude: latitude,
            longitude: longitude,
            timestamp: Date(timeIntervalSince1970: 1_710_000_000 + offsetSeconds),
            horizontalAccuracyM: accuracy
        )
    }
}
