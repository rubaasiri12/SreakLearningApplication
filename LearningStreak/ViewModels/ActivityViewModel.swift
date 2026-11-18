import Foundation
import Combine

// VIEWMODEL — Task 2: Log a day as learned or freezed  (+ Task 3 texts)
// All the Activity rules live here:
//   • Counters start at 0 and count the days logged since the goal started.
//   • Tap "Log as Learned" / "Freeze for a day" to choose today; tap again to undo;
//     switching between them moves the day from one counter to the other (toggle).
//   • Freezes allowed: 2 a week, 8 a month, 96 a year.
//   • Learned + Freezed reaches the goal (7 / 30 / 365) → completed → "Well done!"
//   • More than 32 hours without logging → missed → "You didn't reach your goal this time."
//   • A new day starts at 12 AM.
//   • Writing rule: "1 day", "2 days".
//
// Reads/writes: progress (SwiftData), goal (AppStorage), state (UserDefaults).

final class ActivityViewModel: ObservableObject {
    /// Refreshed every minute and at 12 AM so "today" is always right.
    @Published private(set) var now = Date()

    static let streakWindow: TimeInterval = 32 * 60 * 60   // 32 hours

    private let stores: AppStores
    private var cancellables = Set<AnyCancellable>()

    init(stores: AppStores) {
        self.stores = stores
        // When any storage changes, redraw the screen.
        stores.progress.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        stores.goal.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
        stores.state.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &cancellables)
    }

    // MARK: Header

    let title = "Activity"
    var dateText: String { AppCalendar.fullDateFormatter.string(from: now) }

    // MARK: Week strip

    var weekDays: [Date] { AppCalendar.daysOfWeek(containing: now) }

    func weekdayLetter(_ date: Date) -> String {
        AppCalendar.letterWeekdays[AppCalendar.calendar.component(.weekday, from: date) - 1]
    }

    func dayNumber(_ date: Date) -> String { AppCalendar.dayNumberFormatter.string(from: date) }

    func dayStyle(_ date: Date) -> DayStyle {
        DayStyle(status: stores.progress.days[AppCalendar.key(date)],
                 isToday: AppCalendar.calendar.isDate(date, inSameDayAs: now))
    }

    // MARK: Counters

    var learnedDays: Int { count(.learned) }
    var freezedDays: Int { count(.freezed) }
    var learnedText: String { "\(learnedDays) \(dayWord(learnedDays))" }
    var freezedText: String { "\(freezedDays) \(dayWord(freezedDays))" }
    let learnedLabel = "Learned"
    let freezedLabel = "Freezed"

    // MARK: Today's buttons

    var goalStatus: GoalStatus { stores.state.goalStatus }

    private var todayStatus: DayStatus? { stores.progress.days[AppCalendar.key(now)] }
    var isLearnedToday: Bool { todayStatus == .learned }
    var isFreezedToday: Bool { todayStatus == .freezed }

    private var maxFreezes: Int { stores.goal.goal.duration.maxFreezes }

    /// Freeze can be tapped if today is already freezed (to undo) or Freezes are left.
    var canFreeze: Bool { isFreezedToday || freezedDays < maxFreezes }

    var circleTitle: String { isLearnedToday ? "Logged as Learned" : "Log as Learned" }
    var freezeButtonIsBlue: Bool { canFreeze && !isFreezedToday }
    var freezeTitle: String { freezeButtonIsBlue ? "Freeze for a day" : "Freezed for a day" }
    var freezesUsedText: String { "\(freezedDays) out of \(maxFreezes) Freezes used" }

    // MARK: Task 3 texts

    var finishedIcon: String { goalStatus == .completed ? "hands.clap.fill" : "xmark.seal" }
    var finishedTitle: String { goalStatus == .completed ? "Well done!" : "You didn't reach your goal this time." }
    var finishedSubtitle: String { goalStatus == .completed ? "Ready for your next goal?" : "Want to set another goal?" }
    let setGoalTitle = "Set a goal"

    // MARK: Actions

    func logTapped() { setToday(isLearnedToday ? nil : .learned) }
    func freezeTapped() { setToday(isFreezedToday ? nil : .freezed) }

    /// Updates "today" and applies the 32-hour rule.
    func refresh() {
        now = Date()
        guard stores.state.goalStatus == .active,
              let last = stores.state.lastActionDate,
              now.timeIntervalSince(last) > Self.streakWindow else { return }
        stores.state.setGoalStatus(.missed)
    }

    // MARK: Private

    private func setToday(_ newStatus: DayStatus?) {
        guard stores.state.goalStatus == .active else { return }
        let today = Date()
        guard stores.progress.days[AppCalendar.key(today)] != newStatus else { return }
        if newStatus == .freezed && freezedDays >= maxFreezes { return }   // no Freezes left

        stores.progress.setStatus(newStatus, on: today)                     // SwiftData
        if newStatus != nil { stores.state.setLastActionDate(today) }       // UserDefaults
        now = today

        if learnedDays + freezedDays >= stores.goal.goal.duration.totalDays {
            stores.state.setGoalStatus(.completed)                          // "Well done!"
        }
    }

    /// Days of one kind since the goal started (never below 0).
    private func count(_ kind: DayStatus) -> Int {
        let startKey = AppCalendar.key(stores.goal.goal.startDate)
        return stores.progress.days.filter { $0.key >= startKey && $0.value == kind }.count
    }

    private func dayWord(_ count: Int) -> String { count == 1 ? "day" : "days" }
}
