import PackageDescription

let package = Package(
    name: "foodtruck-api",
    targets: [
	Target(name: "CustomAuthentication"),
        Target(name: "App", dependencies: ["CustomAuthentication"]),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor-community/swiftybeaver-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor/auth-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/validation-provider.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

