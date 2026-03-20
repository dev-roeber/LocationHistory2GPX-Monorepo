import XCTest
@testable import LocationHistoryConsumerAppSupport

final class AppPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "AppPreferencesTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDefaultsAreSensible() {
        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)

            XCTAssertEqual(preferences.distanceUnit, .metric)
            XCTAssertEqual(preferences.startTab, .overview)
            XCTAssertEqual(preferences.preferredMapStyle, .standard)
            XCTAssertTrue(preferences.showsTechnicalImportDetails)
            XCTAssertEqual(preferences.liveTrackingAccuracy, .balanced)
            XCTAssertEqual(preferences.liveTrackingDetail, .balanced)
            XCTAssertFalse(preferences.allowsBackgroundLiveTracking)
            XCTAssertEqual(preferences.liveTrackRecorderConfiguration.maximumAcceptedAccuracyM, 65)
            XCTAssertEqual(preferences.liveTrackRecorderConfiguration.minimumDistanceDeltaM, 15)
        }
    }

    func testStoredValuesAreLoaded() {
        defaults.set(AppDistanceUnitPreference.imperial.rawValue, forKey: "app.preferences.distanceUnit")
        defaults.set(AppStartTabPreference.insights.rawValue, forKey: "app.preferences.startTab")
        defaults.set(AppMapStylePreference.hybrid.rawValue, forKey: "app.preferences.mapStyle")
        defaults.set(false, forKey: "app.preferences.showsTechnicalImportDetails")
        defaults.set(AppLiveTrackingAccuracyPreference.strict.rawValue, forKey: "app.preferences.liveTrackingAccuracy")
        defaults.set(AppLiveTrackingDetailPreference.detailed.rawValue, forKey: "app.preferences.liveTrackingDetail")
        defaults.set(true, forKey: "app.preferences.liveTrackingBackground")

        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)

            XCTAssertEqual(preferences.distanceUnit, .imperial)
            XCTAssertEqual(preferences.startTab, .insights)
            XCTAssertEqual(preferences.preferredMapStyle, .hybrid)
            XCTAssertFalse(preferences.showsTechnicalImportDetails)
            XCTAssertEqual(preferences.liveTrackingAccuracy, .strict)
            XCTAssertEqual(preferences.liveTrackingDetail, .detailed)
            XCTAssertTrue(preferences.allowsBackgroundLiveTracking)
            XCTAssertEqual(preferences.liveTrackRecorderConfiguration.maximumAcceptedAccuracyM, 25)
            XCTAssertEqual(preferences.liveTrackRecorderConfiguration.minimumDistanceDeltaM, 8)
        }
    }

    func testResetRestoresDefaults() {
        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)
            preferences.distanceUnit = .imperial
            preferences.startTab = .export
            preferences.preferredMapStyle = .hybrid
            preferences.showsTechnicalImportDetails = false
            preferences.liveTrackingAccuracy = .strict
            preferences.liveTrackingDetail = .batterySaver
            preferences.allowsBackgroundLiveTracking = true

            preferences.reset()

            XCTAssertEqual(preferences.distanceUnit, .metric)
            XCTAssertEqual(preferences.startTab, .overview)
            XCTAssertEqual(preferences.preferredMapStyle, .standard)
            XCTAssertTrue(preferences.showsTechnicalImportDetails)
            XCTAssertEqual(preferences.liveTrackingAccuracy, .balanced)
            XCTAssertEqual(preferences.liveTrackingDetail, .balanced)
            XCTAssertFalse(preferences.allowsBackgroundLiveTracking)
        }
    }

    func testInvalidStoredValueFallsBackToDefault() {
        defaults.set("nonsense", forKey: "app.preferences.startTab")

        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)

            XCTAssertEqual(preferences.startTab, .overview)
        }
    }

    func testInvalidLiveTrackingValuesFallBackToDefaults() {
        defaults.set("nonsense", forKey: "app.preferences.liveTrackingAccuracy")
        defaults.set("still-nonsense", forKey: "app.preferences.liveTrackingDetail")

        MainActor.assumeIsolated {
            let preferences = AppPreferences(userDefaults: defaults)

            XCTAssertEqual(preferences.liveTrackingAccuracy, .balanced)
            XCTAssertEqual(preferences.liveTrackingDetail, .balanced)
        }
    }
}
