// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// Package definition for GhostingKit, a Swift library for interacting with the Ghost Content API.
///
/// This package provides a convenient way to integrate Ghost content into Swift applications,
/// supporting various Apple platforms including iOS, macOS, tvOS, watchOS, and visionOS.
let package = Package(
  name: "GhostingKit",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
    .visionOS(.v1)
  ],
  products: [
    /// The main GhostingKit library product.
    ///
    /// This static library can be integrated into Swift projects to access Ghost Content API functionality.
    .library(
      name: "GhostingKit",
      type: .static,
      targets: ["GhostingKit"]
    )
  ],
  targets: [
    /// The main target for the GhostingKit library.
    ///
    /// This target contains the core functionality for interacting with the Ghost Content API.
    .target(name: "GhostingKit"),
    
    /// The test target for GhostingKit.
    ///
    /// This target contains unit tests to ensure the proper functioning of the GhostingKit library.
    .testTarget(
      name: "GhostingKitTests",
      dependencies: ["GhostingKit"]
    )
  ]
)
