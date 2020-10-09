// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FSCalendar",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "FSCalendar",
            targets: ["FSCalendar-ObjC"]
        ),
    ],
    targets: [
        .target(
            name: "FSCalendar-ObjC",
            dependencies: [],
            path: "FSCalendar/"
        )
    ]
)
