import Foundation
import XCTest
@testable import LocationHistoryConsumer

final class ContractFixturePresenceTests: XCTestCase {
    func testContractArtifactsExist() throws {
        let expected = [
            "app_export.schema.json",
            "CONTRACT_SOURCE.json",
            "golden_app_export_contract_gate.json",
            "golden_app_export_sample_small.json",
            "golden_app_export_sample_medium.json",
        ]

        let fixtures = try contractFixturesDirectory()
        for name in expected {
            let path = fixtures.appendingPathComponent(name)
            XCTAssertTrue(FileManager.default.fileExists(atPath: path.path), name)
        }
    }

    func testContractVersionMatchesExpectedConsumerSchema() {
        XCTAssertEqual(ContractVersion.currentSchemaVersion, "1.0")
    }

    private func contractFixturesDirectory() throws -> URL {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let direct = root.appendingPathComponent("Fixtures/contract", isDirectory: true)
        if FileManager.default.fileExists(atPath: direct.path) {
            return direct
        }
        let repoRoot = root.deletingLastPathComponent()
        let fallback = repoRoot.appendingPathComponent("Fixtures/contract", isDirectory: true)
        if FileManager.default.fileExists(atPath: fallback.path) {
            return fallback
        }
        throw NSError(domain: "LocationHistoryConsumerTests", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Fixtures/contract not found from current directory"
        ])
    }
}
