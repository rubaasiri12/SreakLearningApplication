import Foundation

// MODEL
// What happened on one day. A day with nothing logged has no DayStatus (nil).

enum DayStatus: String, Codable {
    case learned
    case freezed
}

// MODEL
// Where the current goal stands. Saved with UserDefaults (see Models/Storage/AppStateDefaults.swift).

enum GoalStatus: String, Codable {
    case active      // streak is running (Task 2)
    case completed   // reached the goal → "Well done!" (Task 3)
    case missed      // more than 32 hours without logging → "You didn't reach your goal" (Task 3)
}

// MODEL
// How a day circle should look. The ViewModel picks the style, the View picks the colors.

enum DayStyle {
    case learned   // orange
    case freezed   // blue
    case today     // today, not logged yet
    case normal    // nothing

    init(status: DayStatus?, isToday: Bool) {
        switch status {
        case .learned: self = .learned
        case .freezed: self = .freezed
        case nil: self = isToday ? .today : .normal
        }
    }
}
