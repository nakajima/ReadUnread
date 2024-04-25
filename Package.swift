// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ReadUnread",
	platforms: [.macOS(.v14), .iOS(.v17)],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name: "ReadUnread",
			targets: ["ReadUnread"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-async-algorithms", branch: "main"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "ReadUnread",
			dependencies: [
				.product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
			],
			swiftSettings: [
				.enableUpcomingFeature("StrictConcurrency"),
			]
		),
		.testTarget(
			name: "ReadUnreadTests",
			dependencies: ["ReadUnread"]
		),
	]
)
