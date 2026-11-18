import Foundation
import Combine

// VIEWMODEL — Task 1: Start learning!
// Holds what the user types and picks, and decides what happens on "Start Learning".

final class OnboardingViewModel: ObservableObject {

    // MARK: What the user enters (the View binds to these)

    @Published var topic: String = ""                       // "I want to learn"
    @Published var selectedDuration: GoalDuration = .week   // Week is selected first

    // MARK: Fixed text for the View

    let titleRegular = "Hello"
    let titleBold = "Learner"
    let subtitle = "This app will help you learn everyday!"
    let topicLabel = "I want to learn"
    let topicPlaceholder = "Swift"
    let durationLabel = "I want to learn it in a"
    let startButtonTitle = "Start Learning"
    let footnote = "You can edit your goal later"
    let durations = GoalDuration.allCases

    // MARK: Data

    private let stores: AppStores

    init(stores: AppStores) {
        self.stores = stores
    }

    // MARK: Questions / actions

    func isSelected(_ duration: GoalDuration) -> Bool { selectedDuration == duration }

    func select(_ duration: GoalDuration) { selectedDuration = duration }

    /// "Start Learning" → save the goal (AppStorage) and the state (UserDefaults)
    /// → the app moves to the Activity page. Empty field → the placeholder "Swift".
    func startLearning() {
        let trimmed = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        stores.startNewGoal(LearningGoal(
            topic: trimmed.isEmpty ? topicPlaceholder : trimmed,
            duration: selectedDuration,
            startDate: AppCalendar.startOfDay(Date())
        ))
    }
}
