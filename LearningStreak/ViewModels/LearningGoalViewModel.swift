import Foundation
import Combine

// VIEWMODEL — Goal View: Task 3 "Set a goal" and Task 4 "Change Learning goal"
// Two ways in:
//
//   NEW GOAL mode   (from the Success / Fail page, "Set a goal")
//     • opens EMPTY (Week selected), no back button — ✓ is the only way out
//     • ✓ → start the new goal from 0 → back to the Toggle page
//
//   EDIT mode       (from the pencil icon on the Toggle page)
//     • opens filled with the current goal
//     • something changed → "Update goal" alert (streak starts over)
//     • nothing changed   → just close

final class LearningGoalViewModel: ObservableObject {

    // MARK: What the user edits

    @Published var topic: String
    @Published var selectedDuration: GoalDuration
    @Published var showUpdateAlert = false

    // MARK: Fixed text

    let pageTitle = "Learning Goal"
    let topicLabel = "I want to learn"
    let topicPlaceholder = "Swift"
    let durationLabel = "I want to learn it in a"
    let alertTitle = "Update goal"
    let alertMessage = "If you update now, your streak will start over."
    let dismissTitle = "Dismiss"
    let updateTitle = "Update"
    let durations = GoalDuration.allCases

    /// true = opened from the Success / Fail page ("Set a goal").   ← this was missing
    let isNewGoal: Bool

    // MARK: Data

    private let stores: AppStores

    init(stores: AppStores, isNewGoal: Bool) {                       // ← isNewGoal added here
        self.stores = stores
        self.isNewGoal = isNewGoal
        // New goal (from Success / Fail) → start empty. Edit (pencil) → keep the current goal.
        topic = isNewGoal ? "" : stores.goal.goal.topic
        selectedDuration = isNewGoal ? .week : stores.goal.goal.duration
        print("GOAL VIEW OPENED (\(isNewGoal ? "new goal" : "edit")) → topic: \(topic), duration: \(selectedDuration.title)")
    }

    // MARK: Questions

    func isSelected(_ duration: GoalDuration) -> Bool { selectedDuration == duration }

    private var cleanTopic: String {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? topicPlaceholder : trimmed
    }

    private var hasChanges: Bool {
        cleanTopic != stores.goal.goal.topic || selectedDuration != stores.goal.goal.duration
    }

    // MARK: Actions

    func select(_ duration: GoalDuration) { selectedDuration = duration }

    /// ✓ tapped. Returns `true` when the page should close.
    func checkmarkTapped() -> Bool {
        if isNewGoal || stores.state.goalStatus != .active {   // Task 3: start again from 0
            applyGoal()
            return true
        }
        if hasChanges {                                        // Task 4: warn first
            showUpdateAlert = true
            return false
        }
        return true
    }

    /// "Update" tapped in the alert.
    func confirmUpdate() { applyGoal() }

    private func applyGoal() {
        stores.startNewGoal(LearningGoal(
            topic: cleanTopic,
            duration: selectedDuration,
            startDate: AppCalendar.startOfDay(Date())
        ))
    }
}
