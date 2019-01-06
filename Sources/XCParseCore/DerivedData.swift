import Foundation

/// Contains all the data structures defined there-in. Consumers should use this object directly.
/// Creating this object is very expensive and should done thoughtfully.
public class DerivedData {
    public var manifest: Manifest
    public var pifCache: PIFCache
    public var testRuns: [XCTestRun]

    public convenience init(contentsOfFile path: String) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url)
    }

    public init(contentsOf url: URL) throws {
        guard let buildIntermediateDataURL = URL(string: "Build/Intermediates.noindex/XCBuildData/", relativeTo: url),
            let productsURL = URL(string: "Build/Products/", relativeTo: url) else {
                throw IOError.invalidFilePath(url.path)
        }

        let fileManager = FileManager.default

        let buildIntermediateDataURLs = try fileManager
            .contentsOfDirectory(at: buildIntermediateDataURL,
                                 includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey, .isReadableKey],
                                 options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants])

        guard let manifestURL = buildIntermediateDataURLs.first(where: { $0.lastPathComponent.hasSuffix("-manifest.xcbuild") }) else {
            throw IOError.invalidFilePath(url.path)
        }
        manifest = try Manifest(contentsOf: manifestURL)

        guard let pifCacheURL = buildIntermediateDataURLs.first(where: { $0.lastPathComponent.contains("PIFCache") }) else {
            throw IOError.invalidFilePath(url.path)
        }
        pifCache = try PIFCache(contentsOf: pifCacheURL)

        let testRunURLs = try fileManager
            .contentsOfDirectory(at: productsURL,
                                 includingPropertiesForKeys: [.isReadableKey, .isRegularFileKey],
                                 options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants])
        testRuns = try testRunURLs
            .compactMap { $0.pathExtension == "xctestrun" ? try XCTestRun(contentsOf: $0) : nil }
    }
}
