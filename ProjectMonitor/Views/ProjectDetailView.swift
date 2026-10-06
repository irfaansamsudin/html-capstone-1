import SwiftUI
import SwiftData

/// Everything about one project: status, schedule, budget, milestones and notes.
struct ProjectDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var project: Project

    @State private var isEditing = false
    @State private var isAddingMilestone = false

    var body: some View {
        List {
            overviewSection
            progressSection
            budgetSection
            milestonesSection
            if !project.notes.isEmpty {
                Section("Notes") {
                    Text(project.notes)
                }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit") { isEditing = true }
        }
        .sheet(isPresented: $isEditing) {
            ProjectFormView(project: project)
        }
        .sheet(isPresented: $isAddingMilestone) {
            MilestoneFormView(project: project)
        }
    }

    // MARK: - Sections

    private var overviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text(project.name)
                    .font(.title2.bold())
                if !project.client.isEmpty {
                    Label(project.client, systemImage: "person.2")
                        .foregroundStyle(.secondary)
                }
                if !project.location.isEmpty {
                    Label(project.location, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)

            // Changing these pickers saves immediately, thanks to @Bindable.
            Picker("Status", selection: $project.status) {
                ForEach(ProjectStatus.allCases) { status in
                    Label(status.label, systemImage: status.symbol).tag(status)
                }
            }
            Picker("Phase", selection: $project.phase) {
                ForEach(ProjectPhase.allCases) { phase in
                    Label(phase.label, systemImage: phase.symbol).tag(phase)
                }
            }
        }
    }

    private var progressSection: some View {
        Section("Progress vs Schedule") {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Work done")
                    Spacer()
                    Text(project.progress.asPercent).bold()
                }
                ProgressView(value: project.progress)
                    .tint(project.status.color)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Time used")
                    Spacer()
                    Text(project.timeElapsed.asPercent).bold()
                }
                ProgressView(value: project.timeElapsed)
                    .tint(.gray)
            }
            if project.status != .completed {
                scheduleInsight
            }
            LabeledContent("Start", value: project.startDate.shortDate)
            LabeledContent("Due", value: project.dueDate.shortDate)
            LabeledContent("Time left") {
                Text(project.dueDescription)
                    .foregroundStyle(project.isOverdue ? Color.red : Color.secondary)
            }
        }
    }

    /// Compares work done with time used — a quick "earned value" style check.
    private var scheduleInsight: some View {
        let variance = project.scheduleVariance
        let message: String
        let symbol: String
        let color: Color
        if variance >= 0 {
            message = "Ahead of schedule by \(variance.asPercent)"
            symbol = "arrow.up.right.circle.fill"
            color = .green
        } else if variance > -0.1 {
            message = "Slightly behind schedule (\((-variance).asPercent))"
            symbol = "arrow.right.circle.fill"
            color = .orange
        } else {
            message = "Behind schedule by \((-variance).asPercent)"
            symbol = "arrow.down.right.circle.fill"
            color = .red
        }
        return Label(message, systemImage: symbol)
            .foregroundStyle(color)
            .font(.subheadline.weight(.medium))
    }

    private var budgetSection: some View {
        Section("Budget") {
            LabeledContent("Budget", value: project.budget.asCurrency)
            LabeledContent("Spent", value: project.spent.asCurrency)
            LabeledContent("Remaining") {
                Text((project.budget - project.spent).asCurrency)
                    .foregroundStyle(project.isOverBudget ? Color.red : Color.secondary)
            }
            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: min(project.budgetUsed, 1))
                    .tint(budgetTint)
                Text("\(project.budgetUsed.asPercent) used")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var budgetTint: Color {
        if project.isOverBudget { return .red }
        if project.budgetUsed > 0.9 { return .orange }
        return .accentColor
    }

    private var milestonesSection: some View {
        Section {
            ForEach(project.sortedMilestones) { milestone in
                MilestoneRow(milestone: milestone)
            }
            .onDelete(perform: deleteMilestones)

            Button {
                isAddingMilestone = true
            } label: {
                Label("Add Milestone", systemImage: "plus.circle")
            }
        } header: {
            Text("Milestones (\(project.completedMilestoneCount)/\(project.milestones.count))")
        } footer: {
            Text("Tap a milestone to mark it done. Progress is calculated from completed milestones.")
        }
    }

    private func deleteMilestones(at offsets: IndexSet) {
        let toDelete = offsets.map { project.sortedMilestones[$0] }
        for milestone in toDelete {
            project.milestones.removeAll { $0.persistentModelID == milestone.persistentModelID }
            context.delete(milestone)
        }
    }
}

/// Small sheet for adding a milestone to a project.
struct MilestoneFormView: View {
    @Environment(\.dismiss) private var dismiss
    let project: Project

    @State private var title = ""
    @State private var dueDate = Date.now

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("e.g. Planning approval received", text: $title)
                DatePicker("Due date", selection: $dueDate, displayedComponents: .date)
            }
            .navigationTitle("New Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        project.milestones.append(Milestone(title: trimmedTitle, dueDate: dueDate))
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
