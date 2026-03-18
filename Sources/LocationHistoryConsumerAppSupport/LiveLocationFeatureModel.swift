import Foundation
import Combine

@MainActor
public final class LiveLocationFeatureModel: ObservableObject {
    @Published public private(set) var authorization: LiveLocationAuthorization
    @Published public private(set) var isRecording = false
    @Published public private(set) var isAwaitingAuthorization = false
    @Published public private(set) var currentLocation: LiveLocationSample?
    @Published public private(set) var liveTrackPoints: [RecordedTrackPoint] = []
    @Published public private(set) var recordedTracks: [RecordedTrack] = []
    @Published public private(set) var persistenceErrorMessage: String?

    private let client: LiveLocationClient?
    private let store: RecordedTrackStoring
    private var recorder: LiveTrackRecorder

    public init() {
        self.client = makeDefaultLiveLocationClient()
        self.store = RecordedTrackFileStore()
        self.recorder = LiveTrackRecorder()
        self.authorization = client?.authorization ?? .restricted

        do {
            self.recordedTracks = try store.loadTracks()
        } catch {
            self.recordedTracks = []
            self.persistenceErrorMessage = "Saved live tracks could not be loaded."
        }

        client?.onAuthorizationChange = { [weak self] authorization in
            self?.handleAuthorizationChange(authorization)
        }
        client?.onLocationSamples = { [weak self] samples in
            self?.handleLocationSamples(samples)
        }
    }

    public init(
        client: LiveLocationClient?,
        store: RecordedTrackStoring,
        recorder: LiveTrackRecorder = LiveTrackRecorder()
    ) {
        self.client = client
        self.store = store
        self.recorder = recorder
        self.authorization = client?.authorization ?? .restricted

        do {
            self.recordedTracks = try store.loadTracks()
        } catch {
            self.recordedTracks = []
            self.persistenceErrorMessage = "Saved live tracks could not be loaded."
        }

        client?.onAuthorizationChange = { [weak self] authorization in
            self?.handleAuthorizationChange(authorization)
        }
        client?.onLocationSamples = { [weak self] samples in
            self?.handleLocationSamples(samples)
        }
    }

    public var canDisplayLiveLocation: Bool {
        authorization.allowsForegroundTracking
    }

    public var liveTrackShouldRender: Bool {
        liveTrackPoints.count >= 2
    }

    public var permissionTitle: String {
        switch authorization {
        case .notDetermined:
            return isAwaitingAuthorization ? "Waiting for Location Permission" : "Location Permission Not Requested"
        case .restricted:
            return "Location Access Restricted"
        case .denied:
            return "Location Access Denied"
        case .authorizedWhenInUse, .authorizedAlways:
            return isRecording ? "Recording Live Track" : "Live Location Ready"
        }
    }

    public var permissionMessage: String {
        if let persistenceErrorMessage {
            return persistenceErrorMessage
        }

        switch authorization {
        case .notDetermined:
            return isAwaitingAuthorization
                ? "Approve while-using-the-app access to show your position and start recording."
                : "Turn on live location to request foreground-only access."
        case .restricted:
            return "Location services are restricted on this device. Live recording stays unavailable."
        case .denied:
            return "Enable While Using the App access in Settings to show your position and record live tracks."
        case .authorizedWhenInUse, .authorizedAlways:
            if isRecording {
                if liveTrackPoints.isEmpty {
                    return "Waiting for accurate foreground location updates."
                }
                return "Recording stays local to this app and is saved only when you stop."
            }
            return "Foreground location is authorized. Start recording to show your position and begin a new live track."
        }
    }

    public func setRecordingEnabled(_ enabled: Bool) {
        if enabled {
            startRecordingFlow()
        } else {
            stopRecordingFlow()
        }
    }

    public func refreshAuthorization() {
        authorization = client?.authorization ?? .restricted
    }

    private func startRecordingFlow() {
        persistenceErrorMessage = nil

        guard let client else {
            authorization = .restricted
            return
        }

        switch client.authorization {
        case .authorizedWhenInUse, .authorizedAlways:
            recorder.start()
            liveTrackPoints = []
            isRecording = true
            isAwaitingAuthorization = false
            client.startUpdatingLocation()
        case .notDetermined:
            isAwaitingAuthorization = true
            client.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isAwaitingAuthorization = false
            isRecording = false
        }
    }

    private func stopRecordingFlow() {
        isAwaitingAuthorization = false
        isRecording = false
        client?.stopUpdatingLocation()
        currentLocation = nil

        let finishedTrack = recorder.stop()
        liveTrackPoints = []

        guard let finishedTrack else {
            return
        }

        var updatedTracks = recordedTracks
        updatedTracks.insert(finishedTrack, at: 0)

        do {
            try store.saveTracks(updatedTracks)
            recordedTracks = updatedTracks
        } catch {
            persistenceErrorMessage = "Live track could not be saved."
        }
    }

    private func handleAuthorizationChange(_ authorization: LiveLocationAuthorization) {
        self.authorization = authorization

        guard isAwaitingAuthorization else {
            return
        }

        if authorization.allowsForegroundTracking {
            startRecordingFlow()
        } else {
            isAwaitingAuthorization = false
            isRecording = false
        }
    }

    private func handleLocationSamples(_ samples: [LiveLocationSample]) {
        guard isRecording else {
            return
        }

        guard let bestSample = samples.last(where: isDisplayQuality) ?? samples.last else {
            return
        }

        if isDisplayQuality(bestSample) {
            currentLocation = bestSample
        }

        var recorder = self.recorder
        var didAcceptAnySample = false
        for sample in samples {
            didAcceptAnySample = recorder.append(sample) || didAcceptAnySample
        }
        self.recorder = recorder

        if didAcceptAnySample {
            liveTrackPoints = recorder.points
        }
    }

    private func isDisplayQuality(_ sample: LiveLocationSample) -> Bool {
        sample.horizontalAccuracyM > 0 && sample.horizontalAccuracyM <= 100
    }
}

@MainActor
private func makeDefaultLiveLocationClient() -> LiveLocationClient? {
    #if canImport(CoreLocation)
    return SystemLiveLocationClient()
    #else
    return nil
    #endif
}
