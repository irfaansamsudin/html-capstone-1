import Foundation
import SwiftData

/// Example projects shown on first launch so the app isn't empty.
enum SampleData {
    static func insert(into context: ModelContext) {
        func day(_ offset: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: offset, to: .now) ?? .now
        }

        let library = Project(
            name: "Community Library Extension",
            client: "City Council",
            location: "Jalan Merdeka",
            phase: .designDevelopment,
            status: .onTrack,
            startDate: day(-120),
            dueDate: day(240),
            budget: 4_500_000,
            spent: 1_150_000,
            notes: "Two-storey reading wing with rooftop garden. Coordinate with heritage officer on facade."
        )
        context.insert(library)
        library.milestones.append(contentsOf: [
            Milestone(title: "Client brief signed off", dueDate: day(-110), isDone: true),
            Milestone(title: "Schematic design approved", dueDate: day(-60), isDone: true),
            Milestone(title: "Planning submission", dueDate: day(10)),
            Milestone(title: "Design development complete", dueDate: day(60)),
            Milestone(title: "Tender documents issued", dueDate: day(150)),
        ])

        let clinic = Project(
            name: "District Health Clinic",
            client: "Ministry of Health",
            location: "Taman Seri",
            phase: .construction,
            status: .atRisk,
            startDate: day(-300),
            dueDate: day(60),
            budget: 12_000_000,
            spent: 11_400_000,
            notes: "Steel delivery slipped two weeks. Monitor M&E contractor progress closely."
        )
        context.insert(clinic)
        clinic.milestones.append(contentsOf: [
            Milestone(title: "Groundworks complete", dueDate: day(-200), isDone: true),
            Milestone(title: "Structure topped out", dueDate: day(-90), isDone: true),
            Milestone(title: "Roof watertight", dueDate: day(-5)),
            Milestone(title: "M&E first fix", dueDate: day(20)),
            Milestone(title: "Practical completion", dueDate: day(60)),
        ])

        let plaza = Project(
            name: "Civic Plaza Upgrade",
            client: "Public Works Department",
            location: "Town Centre",
            phase: .tender,
            status: .delayed,
            startDate: day(-200),
            dueDate: day(-10),
            budget: 2_800_000,
            spent: 950_000,
            notes: "Tender re-issued after budget review."
        )
        context.insert(plaza)
        plaza.milestones.append(contentsOf: [
            Milestone(title: "Landscape concept", dueDate: day(-170), isDone: true),
            Milestone(title: "Cost plan approved", dueDate: day(-60), isDone: true),
            Milestone(title: "Tender award", dueDate: day(-10)),
        ])

        let school = Project(
            name: "Public School Block C",
            client: "Ministry of Education",
            location: "Bandar Baru",
            phase: .handover,
            status: .completed,
            startDate: day(-500),
            dueDate: day(-30),
            budget: 6_000_000,
            spent: 5_750_000
        )
        context.insert(school)
        school.milestones.append(contentsOf: [
            Milestone(title: "Practical completion", dueDate: day(-45), isDone: true),
            Milestone(title: "Handover to school", dueDate: day(-30), isDone: true),
        ])
    }
}
