import Foundation
import Combine

// VIEWMODEL — Task 4: Change Learning goal  (also Task 3 "Set a goal")
// Starts filled with the current goal. Tapping ✓:
//   • Goal already ended (Task 3)      → start the new / same goal right away
//   • Something changed during a goal  → show the "Update goal" alert (streak starts over)
//   • Nothing changed                  → just close

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

    // MARK: Data

    private let stores: AppStores

    init(stores: AppStores) {
        self.stores = stores
        topic = stores.goal.goal.topic
        selectedDuration = stores.goal.goal.duration
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
        if stores.state.goalStatus != .active {   // Task 3: nothing to lose
            applyGoal()
            return true
        }
        if hasChanges {                           // Task 4: warn first
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
