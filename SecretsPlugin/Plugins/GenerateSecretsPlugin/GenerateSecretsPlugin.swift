import PackagePlugin
import Foundation

@main
struct GenerateSecretsPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        // SwiftPMターゲット向け（Package.swiftからビルドする場合）
        // Xcodeプロジェクトからは XcodeBuildToolPlugin が使われる
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateSecretsPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let projectRoot = context.xcodeProject.directory
        let inputJSON = projectRoot.appending(subpath: "ios-secrets.json")
        let outputSwift = context.pluginWorkDirectory.appending(subpath: "Secrets.generated.swift")

        return [
            .buildCommand(
                displayName: "Generate Secrets",
                executable: try context.tool(named: "GenerateSecrets").path,
                arguments: [inputJSON.string, outputSwift.string],
                inputFiles: [inputJSON],
                outputFiles: [outputSwift]
            )
        ]
    }
}
#endif
