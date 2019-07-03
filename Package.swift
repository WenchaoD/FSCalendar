import PackageDescription

let package = Package(
    name: "FSCalendar",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "FSCalendar",
            targets: ["FSCalendar"])
    ],
    targets: [
        .target(
            name: "FSCalendar",
            path: "FSCalendar")
    ]
)
