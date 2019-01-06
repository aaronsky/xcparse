import Foundation

public struct XCTestRun: Codable {
    public private(set) var targets: [Target] = []
    public private(set) var metadata: Metadata

    public init(contentsOfFile path: String) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url)
    }

    public init(contentsOf url: URL) throws {
        let decoder = PropertyListDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode(XCTestRun.self, from: data)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        var meta: Metadata?
        for key in container.allKeys {
            if key.stringValue == "__xctestrun_metadata__" {
                meta = try container.decode(Metadata.self, forKey: key)
                continue
            }
            targets.append(try container.decode(Target.self, forKey: key))
        }
        guard let metadata = meta else {
            throw Error.noMetadataFound
        }
        self.metadata = metadata
    }

    public struct Target: Codable {
        public let bundleIdentifiersForCrashReportEmphasis: [String]
        public let clangProfileDataDirectoryPath: String
        public let commandLineArguments: [String]
        public let dependentProductPaths: [String]
        public let environmentVariables: [String: String]
        public let productModuleName: String
        public let runOrder: Int
        public let systemAttachmentLifetime: String
        public let testBundlePath: String
        public let testHostPath: String
        public let testingEnvironmentVariables: [String: String]
        public let toolchainsSettingValue: [String]
        public let uiTargetAppCommandLineArguments: [String]
        public let uiTargetAppMainThreadCheckerEnabled: Bool
        public let userAttachmentLifetime: String

        private enum CodingKeys: String, CodingKey {
            case bundleIdentifiersForCrashReportEmphasis = "BundleIdentifiersForCrashReportEmphasis"
            case clangProfileDataDirectoryPath = "ClangProfileDataDirectoryPath"
            case commandLineArguments = "CommandLineArguments"
            case dependentProductPaths = "DependentProductPaths"
            case environmentVariables = "EnvironmentVariables"
            case productModuleName = "ProductModuleName"
            case runOrder = "RunOrder"
            case systemAttachmentLifetime = "SystemAttachmentLifetime"
            case testBundlePath = "TestBundlePath"
            case testHostPath = "TestHostPath"
            case testingEnvironmentVariables = "TestingEnvironmentVariables"
            case toolchainsSettingValue = "ToolchainsSettingValue"
            case uiTargetAppCommandLineArguments = "UITargetAppCommandLineArguments"
            case uiTargetAppMainThreadCheckerEnabled = "UITargetAppMainThreadCheckerEnabled"
            case userAttachmentLifetime = "UserAttachmentLifetime"
        }
    }

    public struct Metadata: Codable {
        public let codeCoverageBuildableInfos: [CodeCoverageBuildableInfo]
        public let formatVersion: Int

        private enum CodingKeys: String, CodingKey {
            case codeCoverageBuildableInfos = "CodeCoverageBuildableInfos"
            case formatVersion = "FormatVersion"
        }

        public struct CodeCoverageBuildableInfo: Codable {
            public let architecture: String
            public let buildableIdentifier: String
            public let name: String
            public let productPath: String
            public let toolchains: [String]

            private enum CodingKeys: String, CodingKey {
                case architecture = "Architecture"
                case buildableIdentifier = "BuildableIdentifier"
                case name = "Name"
                case productPath = "ProductPath"
                case toolchains = "Toolchains"
            }
        }
    }

    private enum Error: Swift.Error {
        case noMetadataFound
    }
}
