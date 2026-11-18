import Foundation
import Combine

////////////////////////////////////////////////////////////////////////////////
/// DATA STORAGE FOR: THE APP'S STATE                      → UserDefaults
///
/// What it keeps:
///   • hasOnboarded   – did the user finish Onboarding? (picks the first screen)
///   • lastActionDate – last time a day was logged (for the 32-hour rule)
///   • goalStatus     – active / completed / missed
/// Saved and read in code with UserDefaults.
/// Used by: the App (first screen) and all ViewModels.
/// Change this file to change how the app's state is saved.
////////////////////////////////////////////////////////////////////////////////

final class AppStateDefaults: ObservableObject {

    @Published private(set) var hasOnboarded: Bool
    @Published private(set) var lastActionDate: Date?
    @Published private(set) var goalStatus: GoalStatus

    private let defaults: UserDefaults

    private enum Keys {
        static let hasOnboarded = "state.hasOnboarded"
        static let lastActionDate = "state.lastActionDate"
        static let goalStatus = "state.goalStatus"
    }

    /// - Parameter defaults: pass a separate store in previews so real data isn't touched.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasOnboarded = defaults.bool(forKey: Keys.hasOnboarded)
        lastActionDate = defaults.object(forKey: Keys.lastActionDate) as? Date
        goalStatus = GoalStatus(rawValue: defaults.string(forKey: Keys.goalStatus) ?? "") ?? .active
    }

    func setOnboarded(_ value: Bool) {
        hasOnboarded = value
        defaults.set(value, forKey: Keys.hasOnboarded)
    }

    func setLastActionDate(_ date: Date?) {
        lastActionDate = date
        defaults.set(date, forKey: Keys.lastActionDate)
    }

    func setGoalStatus(_ status: GoalStatus) {
        goalStatus = status
        defaults.set(status.rawValue, forKey: Keys.goalStatus)
    }
}
