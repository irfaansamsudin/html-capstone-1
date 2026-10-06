import SwiftUI

/// How healthy a project is right now.
enum ProjectStatus: String, Codable, CaseIterable, Identifiable {
    case onTrack
    case atRisk
    case delayed
    case onHold
    case completed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .onTrack: "On Track"
        case .atRisk: "At Risk"
        case .delayed: "Delayed"
        case .onHold: "On Hold"
        case .completed: "Completed"
        }
    }

    var color: Color {
        switch self {
        case .onTrack: .green
        case .atRisk: .orange
        case .delayed: .red
        case .onHold: .gray
        case .completed: .blue
        }
    }

    var symbol: String {
        switch self {
        case .onTrack: "checkmark.circle"
        case .atRisk: "exclamationmark.triangle"
        case .delayed: "clock.badge.exclamationmark"
        case .onHold: "pause.circle"
        case .completed: "checkmark.seal"
        }
    }
}

/// Typical stages of an architectural project, from brief to handover.
enum ProjectPhase: String, Codable, CaseIterable, Identifiable {
    case concept
    case schematicDesign
    case designDevelopment
    case documentation
    case tender
    case construction
    case handover

    var id: String { rawValue }

    var label: String {
        switch self {
        case .concept: "Concept"
        case .schematicDesign: "Schematic Design"
        case .designDevelopment: "Design Development"
        case .documentation: "Construction Docs"
        case .tender: "Tender"
        case .construction: "Construction"
        case .handover: "Handover"
        }
    }

    var symbol: String {
        switch self {
        case .concept: "lightbulb"
        case .schematicDesign: "pencil.and.outline"
        case .designDevelopment: "square.3.layers.3d"
        case .documentation: "doc.text"
        case .tender: "envelope.badge"
        case .construction: "hammer"
        case .handover: "key"
        }
    }
}
