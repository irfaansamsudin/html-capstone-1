import SwiftUI
import SwiftData

@main
struct ProjectMonitorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Creates the on-device database and shares it with every screen.
        .modelContainer(for: [Project.self, Milestone.self])
    }
}
