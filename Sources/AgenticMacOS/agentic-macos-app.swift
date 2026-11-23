import AgenticApplication
import AgenticHost
import AgenticMacUI
import AgenticRuntime
import Foundation
import SwiftUI

@main
struct AgenticMacOSApp: App {
    var body: some Scene {
        WindowGroup("Agentic") {
            DesktopView {
                try await AgentHost.Local.launch(
                    PrimaryApplication.self,
                    workspace: .init(path: Self.workspace)
                )
            }
        }
    }

    /// The folder agents work in: `defaults write com.leviouwendijk.agentic.macos
    /// workspace <path>`, otherwise the home folder.
    static var workspace: String {
        UserDefaults.standard.string(forKey: "workspace")
            ?? FileManager.default.homeDirectoryForCurrentUser.path
    }
}
