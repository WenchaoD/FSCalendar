// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FSCalendar",
    platforms: [.iOS(.v8)],
    targets: [
        .target(
            name: "FSCalendar-ObjC", // 1
            dependencies: [], // 2
            path: "FSCalendar/", // 3
            cSettings: [
                .headerSearchPath("Internal") // 5
            ]
        )
    ]
)
