// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "InsetPresentation",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "InsetPresentation",
      targets: ["InsetPresentation"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "InsetPresentation",
      dependencies: []),
    .testTarget(
      name: "InsetPresentationTests",
      dependencies: ["InsetPresentation"]),
  ]
)
