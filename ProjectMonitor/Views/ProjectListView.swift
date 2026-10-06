import SwiftUI
import SwiftData

/// All projects, with search, a status filter, add and swipe-to-delete.
struct ProjectListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Project.dueDate) private var projects: [Project]

    @State private var searchText = ""
    @State private var statusFilter: ProjectStatus?
    @State private var isAddingProject = false

    private var filteredProjects: [Project] {
        projects.filter { project in
            let matchesStatus = statusFilter == nil || project.status == statusFilter
            let matchesSearch = searchText.isEmpty
                || project.name.localizedCaseInsensitiveContains(searchText)
                || project.client.localizedCaseInsensitiveContains(searchText)
            return matchesStatus && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "building.2",
                        description: Text("Tap + to add your first project.")
                    )
                } else if filteredProjects.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredProjects) { project in
                            NavigationLink(value: project) {
                                ProjectRow(project: project)
                            }
                        }
                        .onDelete(perform: deleteProjects)
                    }
                }
            }
            .navigationTitle("Projects")
            .navigationDestination(for: Project.self) { ProjectDetailView(project: $0) }
            .searchable(text: $searchText, prompt: "Search name or client")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { filterMenu }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingProject = true
                    } label: {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingProject) {
                ProjectFormView(project: nil)
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Picker("Status", selection: $statusFilter) {
                Text("All").tag(ProjectStatus?.none)
                ForEach(ProjectStatus.allCases) { status in
                    Label(status.label, systemImage: status.symbol).tag(ProjectStatus?.some(status))
                }
            }
        } label: {
            Label(
                "Filter",
                systemImage: statusFilter == nil
                    ? "line.3.horizontal.decrease.circle"
                    : "line.3.horizontal.decrease.circle.fill"
            )
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        let toDelete = offsets.map { filteredProjects[$0] }
        for project in toDelete {
            context.delete(project)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Project.self, Milestone.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SampleData.insert(into: container.mainContext)
    return ProjectListView().modelContainer(container)
}
