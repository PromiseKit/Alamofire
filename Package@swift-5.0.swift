// swift-tools-version:5.0

import PackageDescription

let pkg = Package(name: "PMKAlamofire")
pkg.platforms = [
   .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
]
pkg.products = [
    .library(name: "PMKAlamofire", targets: ["PMKAlamofire"]),
]
pkg.dependencies = [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.0.0"))
]
pkg.swiftLanguageVersions = [.v3, .v4, .v4_2, .v5]

let target: Target = .target(name: "PMKAlamofire")
target.path = "Sources"
target.exclude = ["Tests"]
target.dependencies = [
    "PromiseKit",
    "Alamofire"
]

pkg.targets = [target]
