import Foundation

public struct DependencyGraph: Codable {
    public let nodes: [Node]
    public let links: [Link]

    public init?(_ pifCache: PIFCache) {
        guard let workspace = pifCache.workspaces.first else {
            return nil
        }
        let targets: [String: PIFCache.Target] = workspace
            .projects
            .reduce([:]) { acc, project in
                let targets = Dictionary(uniqueKeysWithValues: project.targets.map { ($0.guid, $0) })
                return acc.merging(targets) { $1 }
        }
        nodes = targets.values.map { Node(id: $0.guid, name: $0.name) }
        links = targets
            .values
            .flatMap { target in target.dependencies.map { Link(source: target.guid, target: targets[$0]?.guid) } }
    }

    public struct Node: Codable {
        public let id: String
        public let name: String
    }

    public struct Link: Codable {
        public let source: String
        public let target: String?
    }
}
