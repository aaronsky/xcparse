import Foundation

public struct DependencyGraph: Codable {
    public var connections: [Connection] = []

    public init(_ pifCache: PIFCache) {
        guard let workspace = pifCache.workspaces.first else {
            return
        }
        let targets: [String: PIFCache.Target] = workspace
            .projects
            .reduce([:]) { acc, project in
                let targets = Dictionary(uniqueKeysWithValues: project.targets.map { ($0.guid, $0) })
                return acc.merging(targets) { $1 }
        }
        connections = targets
            .values
            .flatMap { target in target.dependencies.map { Connection(from: target, to: targets[$0]) } }
    }

    public struct Connection: Codable {
        public let from: PIFCache.Target
        public let to: PIFCache.Target?
    }
}
