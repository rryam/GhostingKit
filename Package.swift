// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PhantomKit",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
    .visionOS(.v1)
  ],
  products: [
    .library(
      name: "PhantomKit",
      type: .static,
      targets: ["PhantomKit"]
    )
  ],
  targets: [
    .target(name: "PhantomKit"),
    .testTarget(
      name: "PhantomKitTests",
      dependencies: ["PhantomKit"]
    )
  ]
)
