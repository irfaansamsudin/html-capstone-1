import Foundation
import SwiftData

/// A project being monitored. `@Model` tells SwiftData to save it on the device.
@Model
final class Project {
    var name: String
    var client: String
    var location: String
    var phase: ProjectPhase
    var status: ProjectStatus
    var startDate: Date
    var dueDate: Date
    var budget: Double
    var spent: Double
    var notes: String
    var createdAt: Date

    /// Deleting a project also deletes its milestones.
    @Relationship(deleteRule: .cascade, inverse: \Milestone.project)
    var milestones: [Milestone] = []

    init(
        name: String,
        client: String = "",
        location: String = "",
        phase: ProjectPhase = .concept,
        status: ProjectStatus = .onTrack,
        startDate: Date = .now,
        dueDate: Date = .now,
        budget: Double = 0,
        spent: Double = 0,
        notes: String = ""
    ) {
        self.name = name
        self.client = client
        self.location = location
        self.phase = phase
        self.status = status
        self.startDate = startDate
        self.dueDate = dueDate
        self.budget = budget
        self.spent = spent
        self.notes = notes
        self.createdAt = .now
    }
}

// MARK: - Derived values (calculated, not stored)

extension Project {
    var sortedMilestones: [Milestone] {
        milestones.sorted { $0.dueDate < $1.dueDate }
    }

    var completedMilestoneCount: Int {
        milestones.filter(\.isDone).count
    }

    /// Work progress, 0...1, based on milestones completed.
    var progress: Double {
        if status == .completed { return 1 }
        guard !milestones.isEmpty else { return 0 }
        return Double(completedMilestoneCount) / Double(milestones.count)
    }

    /// Share of the schedule already used, 0...1.
    var timeElapsed: Double {
        let total = dueDate.timeIntervalSince(startDate)
        guard total > 0 else { return 1 }
        return min(max(Date.now.timeIntervalSince(startDate) / total, 0), 1)
    }

    /// Positive when work is ahead of the calendar, negative when behind.
    var scheduleVariance: Double {
        progress - timeElapsed
    }

    var budgetUsed: Double {
        budget > 0 ? spent / budget : 0
    }

    var isOverBudget: Bool {
        budget > 0 && spent > budget
    }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let due = calendar.startOfDay(for: dueDate)
        return calendar.dateComponents([.day], from: today, to: due).day ?? 0
    }

    var isOverdue: Bool {
        status != .completed && daysRemaining < 0
    }

    var overdueMilestoneCount: Int {
        milestones.filter(\.isOverdue).count
    }

    /// True when something about the project deserves a closer look.
    var needsAttention: Bool {
        guard status != .completed else { return false }
        return status == .atRisk || status == .delayed || isOverdue || isOverBudget || overdueMilestoneCount > 0
    }

    var dueDescription: String {
        if status == .completed { return "Completed" }
        switch daysRemaining {
        case ..<0: return "Overdue by \(-daysRemaining)d"
        case 0: return "Due today"
        default: return "\(daysRemaining)d left"
        }
    }
}
