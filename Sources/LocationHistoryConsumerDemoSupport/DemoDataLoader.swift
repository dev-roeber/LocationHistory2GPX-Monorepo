import Foundation
import LocationHistoryConsumerAppSupport

public typealias DemoContentSource = AppContentSource
public typealias DemoContent = AppSessionContent
public typealias DemoDataLoaderError = AppContentLoaderError

public enum DemoDataLoader {
    public static let defaultFixtureName = AppContentLoader.defaultDemoFixtureName

    public static func loadDefaultContent() throws -> DemoContent {
        try loadContent(named: defaultFixtureName)
    }

    public static func loadContent(named name: String) throws -> DemoContent {
        try AppContentLoader.loadFixtureContent(
            named: name,
            from: Bundle.module,
            source: .demoFixture(name: name)
        )
    }

    public static func loadImportedContent(from url: URL) throws -> DemoContent {
        try AppContentLoader.loadImportedContent(from: url)
    }

    public static func fixtureURL(named name: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw DemoDataLoaderError.fixtureNotFound(name)
        }
        return url
    }
}
