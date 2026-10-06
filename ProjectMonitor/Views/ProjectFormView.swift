import SwiftUI
import SwiftData

/// One form for both creating a new project and editing an existing one.
/// Edits are kept in local @State "drafts" and only written to the project on Save,
/// so Cancel really does discard changes.
struct ProjectFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    /// nil = creating a new project.
    let project: Project?

    @State private var name: String
    @State private var client: String
    @State private var location: String
    @State private var phase: ProjectPhase
    @State private var status: ProjectStatus
    @State private var startDate: Date
    @State private var dueDate: Date
    @State private var budget: Double
    @State private var spent: Double
    @State private var notes: String

    init(project: Project?) {
        self.project = project
        _name = State(initialValue: project?.name ?? "")
        _client = State(initialValue: project?.client ?? "")
        _location = State(initialValue: project?.location ?? "")
        _phase = State(initialValue: project?.phase ?? .concept)
        _status = State(initialValue: project?.status ?? .onTrack)
        _startDate = State(initialValue: project?.startDate ?? .now)
        _dueDate = State(initialValue: project?.dueDate
            ?? Calendar.current.date(byAdding: .month, value: 6, to: .now) ?? .now)
        _budget = State(initialValue: project?.budget ?? 0)
        _spent = State(initialValue: project?.spent ?? 0)
        _notes = State(initialValue: project?.notes ?? "")
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Name", text: $name)
                    TextField("Client / Agency", text: $client)
                    TextField("Location", text: $location)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("Phase", selection: $phase) {
                        ForEach(ProjectPhase.allCases) { Text($0.label).tag($0) }
                    }
                }

                Section("Schedule") {
                    DatePicker("Start", selection: $startDate, displayedComponents: .date)
                    DatePicker("Due", selection: $dueDate, in: startDate..., displayedComponents: .date)
                }

                Section("Budget") {
                    LabeledContent("Budget") {
                        TextField("0", value: $budget, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Spent to date") {
                        TextField("0", value: $spent, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Notes") {
                    TextField("Risks, decisions, reminders…", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(project == nil ? "New Project" : "Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private func save() {
        let target = project ?? Project(name: trimmedName)
        target.name = trimmedName
        target.client = client.trimmingCharacters(in: .whitespacesAndNewlines)
        target.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        target.phase = phase
        target.status = status
        target.startDate = startDate
        target.dueDate = max(dueDate, startDate)
        target.budget = max(budget, 0)
        target.spent = max(spent, 0)
        target.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if project == nil {
            context.insert(target)
        }
        dismiss()
    }
}

#Preview {
    ProjectFormView(project: nil)
        .modelContainer(for: [Project.self, Milestone.self], inMemory: true)
}
