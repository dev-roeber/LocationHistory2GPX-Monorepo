import Foundation

enum TestSupport {
    static func contractFixturesDirectory() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        for _ in 0..<3 {
            let fixtures = candidate.appendingPathComponent("Fixtures/contract", isDirectory: true)
            if FileManager.default.fileExists(atPath: fixtures.path) {
                return fixtures
            }
            candidate.deleteLastPathComponent()
        }

        throw NSError(domain: "LocationHistoryConsumerTests", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Fixtures/contract not found from test sources"
        ])
    }

    static func contractFixtureURL(named name: String) throws -> URL {
        try contractFixturesDirectory().appendingPathComponent(name)
    }

    static func contractFixtureURLs(prefix: String = "golden_", suffix: String = ".json") throws -> [URL] {
        try FileManager.default.contentsOfDirectory(at: contractFixturesDirectory(), includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix(prefix) && $0.lastPathComponent.hasSuffix(suffix) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
