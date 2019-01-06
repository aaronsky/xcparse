import Foundation
import Basic
import Utility
import XCParseCore

let parser = ArgumentParser(usage: "<command> <options>", overview: "Parses xcbuild manifest file")
let pathArgument = parser.add(positional: "Path", kind: String.self)

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
let args = try parser.parse(arguments)

guard let path = args.get(pathArgument) else {
    print("No path was passed")
    exit(1)
}
// let manifest = try Manifest(contentsOfFile: path)
// let xctestrun = try XCTestRun(contentsOfFile: path)
let pifcache = try PIFCache(contentsOfDirectory: path)
print(pifcache.workspaces.first?.projects.count)
