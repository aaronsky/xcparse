import Foundation

public struct PIFCache {
    public let workspaces: [Workspace]
    
    public init(contentsOfDirectory path: String) throws {
        let url = URL(fileURLWithPath: path)
        try self.init(contentsOf: url)
    }
    
    public init(contentsOf url: URL) throws {
        let options = try CodingOptions(url)
        workspaces = try PIFCache.loadContentsOfDirectory(at: options.workspaceURL, options: options)
    }
    
    fileprivate static func loadContentsOfDirectory<T>(at url: URL, options: CodingOptions) throws -> [T] where T: Decodable {
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [])
            .map { try load(at: $0, options: options) }
    }
    
    fileprivate static func load<T>(at url: URL, options: CodingOptions) throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.userInfo = [
            CodingOptions.key: options
        ]
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
    
    fileprivate struct CodingOptions {
        let pifCacheURL: URL
        let workspaceURL: URL
        let projectURL: URL
        let targetURL: URL
        
        init(_ url: URL) throws {
            pifCacheURL = url
            guard let workspaceURL = URL(string: "workspace/", relativeTo: url),
                let projectURL = URL(string: "project/", relativeTo: url),
                let targetURL = URL(string: "target/", relativeTo: url) else {
                    throw IOError.missingPIFCacheDirectories
            }
            self.workspaceURL = workspaceURL
            self.projectURL = projectURL
            self.targetURL = targetURL
        }
        
        static let key = CodingUserInfoKey(rawValue: "com.sky.pifcachecodingoptions")!
    }
    
    public struct Workspace: Codable {
        public let guid: String
        public let name: String
        public let path: String
        public let projects: [Project]
        
        public init(from decoder: Decoder) throws {
            guard let options = decoder.userInfo[CodingOptions.key] as? CodingOptions else {
                throw PIFCache.Error.missingDecoderOptions
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            guid = try container.decode(String.self, forKey: .guid)
            name = try container.decode(String.self, forKey: .name)
            path = try container.decode(String.self, forKey: .path)
            projects = try container.decodeFile(under: options.projectURL,
                                                codingOptions: options,
                                                fromType: [String].self,
                                                forKey: .projects)
        }
    }
    
    public struct Project: Codable {
        public let appPreferencesBuildSettings: AppPreferencesBuildSettings
        public let buildConfigurations: [BuildConfiguration]
        public let defaultConfigurationName: String
        public let developmentRegion: String
        public let groupTree: GroupTree
        public let guid: String
        public let path: String
        public let projectDirectory: String
        public let targets: [Target]        
        
        public init(from decoder: Decoder) throws {
            guard let options = decoder.userInfo[CodingOptions.key] as? CodingOptions else {
                throw PIFCache.Error.missingDecoderOptions
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            appPreferencesBuildSettings = try container.decode(AppPreferencesBuildSettings.self, forKey: .appPreferencesBuildSettings)
            buildConfigurations = try container.decode([BuildConfiguration].self, forKey: .buildConfigurations)
            defaultConfigurationName = try container.decode(String.self, forKey: .defaultConfigurationName)
            developmentRegion = try container.decode(String.self, forKey: .developmentRegion)
            groupTree = try container.decode(GroupTree.self, forKey: .groupTree)
            guid = try container.decode(String.self, forKey: .guid)
            path = try container.decode(String.self, forKey: .path)
            projectDirectory = try container.decode(String.self, forKey: .projectDirectory)
            targets = try container.decodeFile(under: options.targetURL,
                                               codingOptions: options,
                                               fromType: [String].self,
                                               forKey: .targets)
        }
        
        public struct AppPreferencesBuildSettings: Codable {}
        
        public struct BuildConfiguration: Codable {
            public let buildSettings: [String: String]
            public let guid: String
            public let name: String
        }
        
        public struct GroupTree: Codable {
            public let children: [Child]?
            public let guid: String
            public let name: String
            public let path: String
            public let sourceTree: String
            public let type: String
            
            public struct Child: Codable {
                public let guid: String
                public let name: String?
                public let type: String
                public let path: String
                public let fileType: String?
                public let children: [Child]?
                public let sourceTree: String
                public let fileTextEncoding: String?
                public let regionVariantName: String?
            }
        }
    }
    
    public struct Target: Codable {
        public let buildConfigurations: [BuildConfiguration]
        public let buildPhases: [BuildPhase]
        public let buildRules: [BuildRule]
        public let dependencies: [String]
        public let guid: String
        public let isUnitTest: String?
        public let name: String
        public let performanceTestsBaselinesPath: String?
        public let predominantSourceCodeLanguage: String?
        public let productReference: ProductReference?
        public let productTypeIdentifier: String?
        public let provisioningSourceData: [ProvisioningSourceDatum]
        public let type: String
        
        public struct BuildConfiguration: Codable {
            public let baseConfigurationFileReference: String?
            public let buildSettings: [String: String]
            public let guid: String
            public let name: String
        }
        
        public struct BuildPhase: Codable {
            public let buildFiles: [BuildFile]
            public let guid: String
            public let type: String
            public let destinationSubfolder: String?
            public let destinationSubpath: String?
        }
        
        public struct BuildRule: Codable {}
        
        public struct BuildFile: Codable {
            public let fileReference: String?
            public let guid: String
            public let intentsCodegenFiles: String
            public let targetReference: String?
            public let codeSignOnCopy: String?
            public let removeHeadersOnCopy: String?
        }
        
        public struct ProductReference: Codable {
            public let guid: String
            public let name: String
            public let type: String
        }
        
        public struct ProvisioningSourceDatum: Codable {
            public let bundleIdentifierFromInfoPlist: String
            public let configurationName: String
            public let legacyTeamID: String
            public let provisioningStyle: Int
        }
    }
    
    private enum Error: Swift.Error {
        case missingDecoderOptions
    }
}

private extension KeyedDecodingContainer {
    func decodeFile<T: Decodable>(under url: URL, codingOptions options: PIFCache.CodingOptions, fromType type: String.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T {
        let file = try self.decode(type.self, forKey: key)
        return try loadFile(file, under: url, codingOptions: options)
    }
    
    func decodeFile<T: Decodable>(under url: URL, codingOptions options: PIFCache.CodingOptions, fromType type: [String].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [T] {
        return try self.decode(type.self, forKey: key)
            .map { try loadFile($0, under: url, codingOptions: options) }
    }
    
    private func loadFile<T: Decodable>(_ file: String, under url: URL, codingOptions options: PIFCache.CodingOptions) throws -> T {
        guard let fileURL = URL(string: "\(file)-json", relativeTo: url) else {
            throw IOError.invalidFilePath(file)
        }
        return try PIFCache.load(at: fileURL, options: options)
    }
}
