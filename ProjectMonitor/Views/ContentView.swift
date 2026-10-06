import SwiftUI
import SwiftData

/// The root of the app: two tabs, Dashboard and Projects.
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("hasSeededSampleData") private var hasSeededSampleData = false

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.50percent") }

            ProjectListView()
                .tabItem { Label("Projects", systemImage: "building.2") }
        }
        .task {
            guard !hasSeededSampleData else { return }
            SampleData.insert(into: context)
            hasSeededSampleData = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Project.self, Milestone.self], inMemory: true)
}
