// swift-tools-version: 6.2

import Foundation
import PackageDescription

let packagedirectory = URL(
    fileURLWithPath: #filePath
).deletingLastPathComponent()

let infoPlistPath = packagedirectory.appendingPathComponent(
    "Support/Info.plist"
).path

let package = Package(
    name: "AgenticCLI",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .executable(
            name: "agentic",
            targets: [
                "AgenticCLI",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Agentic.git",
            branch: "master"
        ),

        .package(
            url: "https://github.com/leviouwendijk/AgenticProviders.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticRuntime.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticHost.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticInterfaces.git",
            branch: "master"
        ),

        .package(
            url: "https://github.com/leviouwendijk/Milieu.git",
            branch: "master"
        ),

        // additional domains
        .package(
            url: "https://github.com/leviouwendijk/UniFi.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticIO.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticDomains.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticMedia.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticAccounting.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/AgenticPDF.git",
            branch: "master"
        ),
    ],
    targets: [
        .executableTarget(
            name: "AgenticCLI",
            dependencies: [
                // core lib
                .product(
                    name: "Agentic",
                    package: "Agentic"
                ),
                .product(
                    name: "Milieu",
                    package: "Milieu"
                ),

                // models
                .product(
                    name: "AgenticModels",
                    package: "Agentic"
                ),

                // runtime, host, tui
                .product(
                    name: "AgenticRuntime",
                    package: "AgenticRuntime"
                ),
                .product(
                    name: "AgenticHost",
                    package: "AgenticHost"
                ),
                .product(
                    name: "AgenticCommandLine",
                    package: "AgenticHost"
                ),
                .product(
                    name: "AgenticTUI",
                    package: "AgenticHost"
                ),
                .product(
                    name: "AgenticInterfaces",
                    package: "AgenticInterfaces"
                ),

                // domains
                // [core]
                .product(
                    name: "AgenticSessions",
                    package: "Agentic"
                ),
                .product(
                    name: "AgenticStandard",
                    package: "Agentic"
                ),
                .product(
                    name: "AgenticHarness",
                    package: "Agentic"
                ),
                .product(
                    name: "AgenticMath",
                    package: "Agentic"
                ),
                .product(
                    name: "AgenticAssertions",
                    package: "Agentic"
                ),
                .product(
                    name: "AgenticTasks",
                    package: "Agentic"
                ),
                // [repositories]
                .product(
                    name: "AgenticIO",
                    package: "AgenticIO"
                ),
                .product(
                    name: "AgenticGit",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticSwift",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticWeb",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticAppleServices",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticUniFi",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticProcesses",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "AgenticDevelopment",
                    package: "AgenticDomains"
                ),
                .product(
                    name: "UniFi",
                    package: "UniFi"
                ),
                .product(
                    name: "UniFiPlanning",
                    package: "UniFi"
                ),
                .product(
                    name: "AgenticMedia",
                    package: "AgenticMedia"
                ),
                .product(
                    name: "AgenticMediaApple",
                    package: "AgenticMedia"
                ),
                .product(
                    name: "AgenticAccounting",
                    package: "AgenticAccounting"
                ),

                // model providers and gateways
                .product(
                    name: "AgenticApple",
                    package: "AgenticProviders"
                ),
                .product(
                    name: "AgenticAWS",
                    package: "AgenticProviders"
                ),
                .product(
                    name: "AgenticOllama",
                    package: "AgenticProviders"
                ),
                .product(
                    name: "AgenticHYAI",
                    package: "AgenticProviders"
                ),
                .product(
                    name: "AgenticOpenAI",
                    package: "AgenticProviders"
                ),
                .product(
                    name: "AgenticAnthropic",
                    package: "AgenticProviders"
                ),
            ],
            linkerSettings: [
                .unsafeFlags(
                    [
                        "-Xlinker", "-sectcreate",
                        "-Xlinker", "__TEXT",
                        "-Xlinker", "__info_plist",
                        "-Xlinker", infoPlistPath,
                    ]
                ),
            ]
        ),
    ]
)

for target in package.targets {
    switch target.type {
    case .regular, .executable, .test, .macro:
        var settings = target.swiftSettings ?? []

        settings.append(
            .treatAllWarnings(as: .error)
        )

        settings.append(
            .unsafeFlags(
                [
                    "-continue-building-after-errors"
                ]
            )
        )

        target.swiftSettings = settings

    case .plugin, .system, .binary:
        break

    @unknown default:
        break
    }
}
