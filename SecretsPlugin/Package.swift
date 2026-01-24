// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SecretsPlugin",
    platforms: [.macOS(.v13)],
    products: [
        .plugin(name: "GenerateSecretsPlugin", targets: ["GenerateSecretsPlugin"]),
    ],
    targets: [
        .plugin(
            name: "GenerateSecretsPlugin",
            capability: .buildTool(),
            dependencies: ["GenerateSecrets"]
        ),
        .executableTarget(
            name: "GenerateSecrets"
        ),
    ]
)
