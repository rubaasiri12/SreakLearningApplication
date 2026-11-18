import SwiftUI
import Combine

////////////////////////////////////////////////////////////////////////////////
/// DATA STORAGE FOR: THE LEARNING GOAL                    → AppStorage
///
/// What it keeps: the goal the user typed ("Swift", "Do the homework"...),
/// its duration (Week / Month / Year) and the day it started.
/// Small values → AppStorage.
/// Used by: OnboardingViewModel (Task 1), ActivityViewModel (Task 2),
///          LearningGoalViewModel (Task 3 / Task 4).
/// Change this file to change how the goal is saved.
////////////////////////////////////////////////////////////////////////////////

final class GoalAppStorage: ObservableObject {

    /// AppStorage key: the goal text.
    @AppStorage private var storedTopic: String
    /// AppStorage key: Week / Month / Year.
    @AppStorage private var storedDuration: GoalDuration
    /// AppStorage key: start day, saved as seconds since 1970.
    @AppStorage private var storedStartDate: Double

    private enum Keys {
        static let topic = "goal.topic"
        static let duration = "goal.duration"
        static let startDate = "goal.startDate"
    }

    /// - Parameter store: pass a separate store in previews so the real goal isn't touched.
    init(store: UserDefaults = .standard) {
        _storedTopic = AppStorage(wrappedValue: "", Keys.topic, store: store)
        _storedDuration = AppStorage(wrappedValue: .week, Keys.duration, store: store)
        _storedStartDate = AppStorage(wrappedValue: 0, Keys.startDate, store: store)
    }

    /// The saved goal.
    var goal: LearningGoal {
        LearningGoal(topic: storedTopic,
                     duration: storedDuration,
                     startDate: Date(timeIntervalSince1970: storedStartDate))
    }

    func save(_ newGoal: LearningGoal) {
        objectWillChange.send()   // tell the screens to redraw
        storedTopic = newGoal.topic
        storedDuration = newGoal.duration
        storedStartDate = newGoal.startDate.timeIntervalSince1970
    }
}
