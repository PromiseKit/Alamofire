import PackageDescription

let package = Package(
    name: "PMKAlamofire",
    dependencies: [
// Switch this back before integrating:
//      .Package(url: "https://github.com/mxcl/PromiseKit.git", majorVersion: 4),
        .Package(url: "https://github.com/dougzilla32/PromiseKitCoreCancel.git", majorVersion: 6),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4)
    ],
    exclude: ["Tests"]
)
