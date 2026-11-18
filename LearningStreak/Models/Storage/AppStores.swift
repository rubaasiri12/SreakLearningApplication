import Foundation

// MODEL
// One bundle holding the three storages, so they can be handed to the ViewModels together.
//
//   progress → ProgressStorageDB  (SwiftData)    every logged day
//   goal     → GoalAppStorage     (AppStorage)   the learning goal
//   state    → AppStateDefaults   (UserDefaults) onboarding, last log time, goal status

struct AppStores {
    let progress: ProgressStorageDB
    let goal: GoalAppStorage
    let state: AppStateDefaults

    /// Real app: everything saved on the phone.
    static func live() -> AppStores {
        AppStores(progress: ProgressStorageDB(),
                  goal: GoalAppStorage(),
                  state: AppStateDefaults())
    }

    /// Starts a goal from zero (Task 1 and Task 3 / 4):
    /// save the goal, today is fresh, status active, the 32-hour clock starts now.
    /// Old days stay in the database (for the calendar) but don't count for the new goal.
    func startNewGoal(_ newGoal: LearningGoal) {
        goal.save(newGoal)
        progress.setStatus(nil, on: Date())
        state.setGoalStatus(.active)
        state.setLastActionDate(Date())
        state.setOnboarded(true)
    }
}

// MARK: - Preview data (Xcode canvas only — nothing is saved on the phone)

extension AppStores {
    static func preview(learned: Int = 0,
                        freezed: Int = 0,
                        today: DayStatus? = nil,
                        duration: GoalDuration = .week,
                        status: GoalStatus = .active,
                        onboarded: Bool = true) -> AppStores {
        let store = UserDefaults(suiteName: "preview-\(UUID().uuidString)") ?? .standard
        let stores = AppStores(progress: ProgressStorageDB(inMemory: true),
                               goal: GoalAppStorage(store: store),
                               state: AppStateDefaults(defaults: store))
        guard onboarded else { return stores }

        let cal = AppCalendar.calendar
        if let today { stores.progress.setStatus(today, on: Date()) }
        let pastFreezed = max(freezed - (today == .freezed ? 1 : 0), 0)
        let pastLearned = max(learned - (today == .learned ? 1 : 0), 0)
        var daysBack = 1
        for _ in 0..<pastFreezed {
            if let d = cal.date(byAdding: .day, value: -daysBack, to: Date()) { stores.progress.setStatus(.freezed, on: d) }
            daysBack += 1
        }
        for _ in 0..<pastLearned {
            if let d = cal.date(byAdding: .day, value: -daysBack, to: Date()) { stores.progress.setStatus(.learned, on: d) }
            daysBack += 1
        }
        let start = cal.date(byAdding: .day, value: -(daysBack - 1), to: AppCalendar.startOfDay(Date())) ?? Date()

        stores.goal.save(LearningGoal(topic: "Swift", duration: duration, startDate: start))
        stores.state.setOnboarded(true)
        stores.state.setLastActionDate(Date())
        stores.state.setGoalStatus(status)
        return stores
    }
}
