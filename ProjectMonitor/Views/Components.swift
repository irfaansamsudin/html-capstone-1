import SwiftUI

/// Small coloured pill showing a project's status.
struct StatusBadge: View {
    let status: ProjectStatus

    var body: some View {
        Label(status.label, systemImage: status.symbol)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(status.color)
            .background(status.color.opacity(0.15), in: Capsule())
    }
}

/// A number with a caption, used on the dashboard.
struct StatCard: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(tint)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// A titled, rounded panel for grouping dashboard content.
struct DashboardCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

/// One project in a list: name, client, status and progress bar.
struct ProjectRow: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.headline)
                    Text([project.client, project.phase.label].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusBadge(status: project.status)
            }

            ProgressView(value: project.progress)
                .tint(project.status.color)

            HStack {
                Text("\(project.progress.asPercent) complete")
                Spacer()
                Text(project.dueDescription)
                    .foregroundStyle(project.isOverdue ? Color.red : Color.secondary)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// A tappable checklist row for a milestone.
struct MilestoneRow: View {
    @Bindable var milestone: Milestone

    var body: some View {
        Button {
            withAnimation { milestone.isDone.toggle() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: milestone.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(milestone.isDone ? Color.green : Color.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.title)
                        .strikethrough(milestone.isDone)
                        .foregroundStyle(milestone.isDone ? Color.secondary : Color.primary)
                    Text(milestone.isOverdue ? "Overdue · \(milestone.dueDate.shortDate)" : milestone.dueDate.shortDate)
                        .font(.caption)
                        .foregroundStyle(milestone.isOverdue ? Color.red : Color.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
