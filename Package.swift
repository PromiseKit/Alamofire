// swift-tools-version:5.1
//
//  Package.swift
//
import PackageDescription

let package = Package(name: "PMKAlamofire",
                      platforms: [.macOS(.v10_12),
                                  .iOS(.v10),
                                  .tvOS(.v10),
                                  .watchOS(.v3)],
                      products: [.library(name: "PMKAlamofire",
                                          targets: ["PMKAlamofire"])],
                      dependencies: [
                        .package(
                            url: "https://github.com/mxcl/PromiseKit.git",
                            from: "6.0.0"
                        ),
                        .package(
                            url: "https://github.com/Alamofire/Alamofire.git",
                            from: "5.0.0"
                        )],
                      targets: [.target(name: "PMKAlamofire",
                                        dependencies: ["PromiseKit","Alamofire"],
                                        path: "Sources"
                                        ),
                         /*       .testTarget(name: "PMKAFTests",
                                            dependencies: ["PMKAlamofire"],
                                            path: "Tests")*/],
                      
                      swiftLanguageVersions: [.v5])

