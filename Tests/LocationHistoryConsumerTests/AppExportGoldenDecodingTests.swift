import Foundation
import XCTest
@testable import LocationHistoryConsumer

final class AppExportGoldenDecodingTests: XCTestCase {
    func testDecodesAllGoldenAppExports() throws {
        let files = try contractFixtureURLs(prefix: "golden_app_export_", suffix: ".json")
        XCTAssertFalse(files.isEmpty)

        for fileURL in files {
            let export = try AppExportDecoder.decode(contentsOf: fileURL)
            XCTAssertEqual(export.schemaVersion.rawValue, ContractVersion.currentSchemaVersion, fileURL.lastPathComponent)
        }
    }

    func testDecodesDeterministicContractGoldenAndChecksCoreFields() throws {
        let fileURL = try contractFixturesDirectory().appendingPathComponent("golden_app_export_contract_gate.json")
        let export = try AppExportDecoder.decode(contentsOf: fileURL)

        XCTAssertEqual(export.schemaVersion.rawValue, "1.0")
        XCTAssertEqual(export.meta.exportedAt, "2024-01-02T03:04:05Z")
        XCTAssertEqual(export.meta.source.zipBasename, "fixture_records_public.json")
        XCTAssertEqual(export.meta.source.inputFormat, "records")
        XCTAssertEqual(export.meta.config.mode, "all")
        XCTAssertEqual(export.meta.config.splitMode, "single")
        XCTAssertEqual(export.meta.filters.limit, 5)
        XCTAssertEqual(export.data.days.count, 3)
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

    private func contractFixtureURLs(prefix: String, suffix: String) throws -> [URL] {
        let directory = try contractFixturesDirectory()
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix(prefix) && $0.lastPathComponent.hasSuffix(suffix) }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
