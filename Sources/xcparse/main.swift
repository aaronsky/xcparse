import Foundation
import Basic
import Utility
import XCParseCore

enum Report: String, CaseIterable, StringEnumArgument {
    case none
    case json

    static var completion: ShellCompletion = .values(Report.allCases.map { ($0.rawValue, "") })
}

func printAsJSON(_ graph: DependencyGraph) throws {
    let data = try JSONEncoder().encode(graph)
    guard let json = String(data: data, encoding: .utf8) else {
        return
    }
    print(json)
}

func printStdOut(_ graph: DependencyGraph) {
    for connection in graph.links {
        let from = connection.source
        let to = connection.target ?? "<NULL>"
        print(from, "~>", to)
    }
    print(graph.links.count, "connections in all")
}

let start = Date()

let parser = ArgumentParser(usage: "<command> <options>", overview: "Parses xcbuild manifest file")
let reportArgument = parser.add(option: "--report", shortName: "-r", kind: Report.self)
let pathArgument = parser.add(positional: "Path", kind: PathArgument.self)

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
let args = try parser.parse(arguments)

guard let pathArg = args.get(pathArgument) else {
    print("No path was passed")
    exit(1)
}
let path = pathArg.path.asString

let derivedData = try DerivedData(contentsOfFile: path)
guard let dependencyGraph = DependencyGraph(derivedData.pifCache) else {
    print("PIFCache has no workspaces, so a graph could not be created")
    exit(1)
}

switch args.get(reportArgument) {
case .some(.json):
    try printAsJSON(dependencyGraph)
default:
    printStdOut(dependencyGraph)
    print("Ok in \(String(format: "%.2f", start.timeIntervalSinceNow * -1)) seconds...")
}
