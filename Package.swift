import PackageDescription

let package = Package(
    name: "foodtruck-api",
    targets: [
        Target(name: "App"),
        Target(name: "Run", dependencies: ["App"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor-community/swiftybeaver-provider.git", majorVersion: 1),
        .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
