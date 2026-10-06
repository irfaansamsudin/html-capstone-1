import SwiftUI
import SwiftData
import Charts

/// Portfolio overview: key numbers, status chart, budget and what needs attention.
struct DashboardView: View {
    @Query(sort: \Project.dueDate) private var projects: [Project]
    @Query(filter: #Predicate<Milestone> { $0.isDone == false }, sort: \Milestone.dueDate)
    private var openMilestones: [Milestone]

    private var activeProjects: [Project] {
        projects.filter { $0.status != .completed }
    }

    private var projectsNeedingAttention: [Project] {
        activeProjects.filter(\.needsAttention)
    }

    private var overdueMilestones: [Milestone] {
        openMilestones.filter(\.isOverdue)
    }

    /// Open milestones due within the next 30 days.
    private var upcomingMilestones: [Milestone] {
        let today = Calendar.current.startOfDay(for: .now)
        let limit = Calendar.current.date(byAdding: .day, value: 30, to: today) ?? today
        return Array(openMilestones.filter { $0.dueDate >= today && $0.dueDate <= limit }.prefix(6))
    }

    private var totalBudget: Double { activeProjects.reduce(0) { $0 + $1.budget } }
    private var totalSpent: Double { activeProjects.reduce(0) { $0 + $1.spent } }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "Nothing to Monitor Yet",
                        systemImage: "building.2",
                        description: Text("Add a project in the Projects tab.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            statGrid
                            statusChart
                            budgetCard
                            attentionCard
                            upcomingCard
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: Project.self) { ProjectDetailView(project: $0) }
        }
    }

    // MARK: - Sections

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Active projects", value: "\(activeProjects.count)", symbol: "hammer", tint: .blue)
            StatCard(title: "Need attention", value: "\(projectsNeedingAttention.count)", symbol: "exclamationmark.triangle", tint: .orange)
            StatCard(title: "Completed", value: "\(projects.count - activeProjects.count)", symbol: "checkmark.seal", tint: .green)
            StatCard(title: "Overdue milestones", value: "\(overdueMilestones.count)", symbol: "calendar.badge.exclamationmark", tint: .red)
        }
    }

    private var statusChart: some View {
        DashboardCard(title: "Projects by Status") {
            Chart(ProjectStatus.allCases) { status in
                let count = projects.filter { $0.status == status }.count
                BarMark(
                    x: .value("Projects", count),
                    y: .value("Status", status.label)
                )
                .foregroundStyle(status.color)
                .annotation(position: .trailing) {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 180)
        }
    }

    private var budgetCard: some View {
        DashboardCard(title: "Budget (Active Projects)") {
            let used = totalBudget > 0 ? totalSpent / totalBudget : 0
            ProgressView(value: min(used, 1))
                .tint(used > 1 ? Color.red : Color.accentColor)
            HStack {
                VStack(alignment: .leading) {
                    Text("Spent").font(.caption).foregroundStyle(.secondary)
                    Text(totalSpent.asCurrency).font(.subheadline.bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total budget").font(.caption).foregroundStyle(.secondary)
                    Text(totalBudget.asCurrency).font(.subheadline.bold())
                }
            }
            Text("\(used.asPercent) of budget used")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var attentionCard: some View {
        DashboardCard(title: "Needs Attention") {
            if projectsNeedingAttention.isEmpty {
                Label("All projects are healthy", systemImage: "hand.thumbsup")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(projectsNeedingAttention) { project in
                    NavigationLink(value: project) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name).font(.subheadline.bold())
                                Text(attentionReason(for: project))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusBadge(status: project.status)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var upcomingCard: some View {
        DashboardCard(title: "Upcoming Milestones (30 days)") {
            if upcomingMilestones.isEmpty {
                Text("No milestones due soon.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcomingMilestones) { milestone in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(milestone.title).font(.subheadline)
                            Text(milestone.project?.name ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(milestone.dueDate.shortDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    /// A short, human-readable explanation of why a project is flagged.
    private func attentionReason(for project: Project) -> String {
        var reasons: [String] = []
        if project.isOverdue { reasons.append(project.dueDescription) }
        if project.isOverBudget { reasons.append("Over budget") }
        if project.overdueMilestoneCount > 0 {
            reasons.append("\(project.overdueMilestoneCount) overdue milestone(s)")
        }
        if reasons.isEmpty { reasons.append(project.status.label) }
        return reasons.joined(separator: " · ")
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Project.self, Milestone.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SampleData.insert(into: container.mainContext)
    return DashboardView().modelContainer(container)
}
