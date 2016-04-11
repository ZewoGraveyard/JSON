import PackageDescription

let package = Package(
    name: "JSON",
    dependencies: [
        .Package(url: "https://github.com/Zewo/InterchangeData.git", majorVersion: 0, minor: 3)
    ]
)
