import Foundation

// MODEL
// The three durations the user can pick: Week, Month, Year.

enum GoalDuration: String, CaseIterable, Codable, Identifiable {
    case week, month, year

    var id: String { rawValue }

    /// Text shown on the chip: "Week", "Month", "Year".
    var title: String { rawValue.capitalized }

    /// Logged days (learned + freezed) needed to complete the goal.
    var totalDays: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }

    /// Freezes allowed: 2 in a week, 8 in a month, 96 in a year.
    var maxFreezes: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
}
