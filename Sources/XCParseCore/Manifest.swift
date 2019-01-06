import Foundation
import Yams

public struct Manifest: Codable {
    public let client: Client
    public let targets: [Target]
    public let nodes: [Node]
    public let commands: [Command]

    public init(contentsOfFile path: String) throws {
        guard let url = URL(string: path) else {
            throw IOError.invalidFilePath(path)
        }
        try self.init(contentsOf: url)
    }

    public init(contentsOf url: URL) throws {
        let decoder = YAMLDecoder()
        let manifestFile = try String(contentsOf: url)
        self = try decoder.decode(from: manifestFile)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        client = try container.decode(Client.self, forKey: .client)
        targets = try container.decode([String: [String]].self, forKey: .targets)
            .map { Target(name: $0.key, values: $0.value) }
        nodes = try container.decode([String: Node.Properties].self, forKey: .nodes)
            .map { Node(path: $0.key, properties: $0.value) }
        commands = try container.decode([String: Command.Properties].self, forKey: .commands)
            .map { Command(command: $0.key, properties: $0.value) }
    }

    public struct Client: Codable {
        public let name: String
        public let version: Int
        public let fileSystem: String

        private enum CodingKeys: String, CodingKey {
            case name
            case version
            case fileSystem = "file-system"
        }
    }

    public struct Target: Codable {
        public let name: String
        public let values: [String]
    }

    public struct Node: Codable {
        public let path: String
        public let properties: Properties

        public struct Properties: Codable {
            public let isMutated: Bool?
            public let isCommandTimestamp: Bool?

            private enum CodingKeys: String, CodingKey {
                case isMutated = "is-mutated"
                case isCommandTimestamp = "is-command-timestamp"
            }
        }
    }

    public struct Command: Codable {
        public let command: String
        public let properties: Properties

        public struct Properties: Codable {
            public let tool: String
            public let description: String
            public let inputs: [String]
            public let outputs: [String]
            public let args: [String]
            public let env: [String: String]
            public let deps: [String]
            public let depsStyle: String?
            public let signature: String?

            private enum CodingKeys: String, CodingKey {
                case tool
                case description
                case inputs
                case outputs
                case args
                case env
                case deps
                case depsStyle = "deps-style"
                case signature
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                tool = try container.decode(String.self, forKey: .tool)
                description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
                inputs = try container.decodeIfPresent([String].self, forKey: .inputs) ?? []
                outputs = try container.decodeIfPresent([String].self, forKey: .outputs) ?? []
                args = try container.decodeIfPresent([String].self, forKey: .args) ?? []
                env = try container.decodeIfPresent([String: String].self, forKey: .env) ?? [:]
                if let value = try? container.decode(String.self, forKey: .deps) {
                    deps = [value]
                } else {
                    deps = try container.decodeIfPresent([String].self, forKey: .deps) ?? []
                }
                depsStyle = try container.decodeIfPresent(String.self, forKey: .depsStyle)
                signature = try container.decodeIfPresent(String.self, forKey: .signature)
            }
        }
    }

}
