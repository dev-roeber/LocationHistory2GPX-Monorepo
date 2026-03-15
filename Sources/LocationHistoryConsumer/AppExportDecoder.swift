import Foundation

public enum AppExportDecoder {
    public static func decode(data: Data) throws -> AppExport {
        let decoder = JSONDecoder()
        return try decoder.decode(AppExport.self, from: data)
    }

    public static func decode(contentsOf url: URL) throws -> AppExport {
        let data = try Data(contentsOf: url)
        return try decode(data: data)
    }
}
