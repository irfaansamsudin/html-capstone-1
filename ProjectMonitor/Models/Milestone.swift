import Foundation
import SwiftData

/// A checkpoint within a project, e.g. "Planning approval submitted".
@Model
final class Milestone {
    var title: String
    var dueDate: Date
    var isDone: Bool
    var project: Project?

    init(title: String, dueDate: Date, isDone: Bool = false) {
        self.title = title
        self.dueDate = dueDate
        self.isDone = isDone
    }

    var isOverdue: Bool {
        !isDone && dueDate < Calendar.current.startOfDay(for: .now)
    }
}
