import Foundation

// MODEL
// What the user wants to learn, for how long, and when they started.
// Saved with AppStorage (see Models/Storage/GoalAppStorage.swift).

struct LearningGoal: Equatable {
    var topic: String            // "Swift", "Do the homework", "Build something"
    var duration: GoalDuration   // .week / .month / .year
    var startDate: Date          // the day the goal started; only days from here on are counted
}
