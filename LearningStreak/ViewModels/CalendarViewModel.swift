import Foundation
import Combine

// VIEWMODEL — Task 5: Open Calendar to see all previous learned days
// Prepares the months and the style of every day from the SwiftData StorageDB.
// View only — nothing to tap.

final class CalendarViewModel: ObservableObject {

    // MARK: Fixed text

    let pageTitle = "Activities"

    // MARK: Data

    private let stores: AppStores
    private var cancellables = Set<AnyCancellable>()

    init(stores: AppStores) {
        self.stores = stores
        // When the logged days change, redraw.
        stores.progress.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: For the View

    /// "SUN", "MON", ...
    var weekdaySymbols: [String] { AppCalendar.shortWeekdays }

    /// From the first logged month (at least 3 months back) up to this month.
    var months: [Date] {
        let cal = AppCalendar.calendar
        let current = AppCalendar.startOfMonth(Date())
        let threeBack = cal.date(byAdding: .month, value: -2, to: current) ?? current
        let earliestLogged = stores.progress.days.keys
            .compactMap { AppCalendar.keyFormatter.date(from: $0) }
            .min()
        let earliest = AppCalendar.startOfMonth(earliestLogged ?? threeBack)

        var result: [Date] = []
        var cursor = min(earliest, threeBack)
        while cursor <= current {
            result.append(cursor)
            guard let next = cal.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result
    }

    /// The month to scroll to when the page opens.
    var currentMonth: Date? { months.last }

    func monthTitle(_ month: Date) -> String { AppCalendar.monthYearFormatter.string(from: month) }

    func grid(for month: Date) -> [Date?] { AppCalendar.monthGrid(for: month) }

    func dayNumber(_ date: Date) -> String { AppCalendar.dayNumberFormatter.string(from: date) }

    /// Learned → orange, Freezed → blue, today (not logged) → solid orange, else plain.
    func dayStyle(_ date: Date) -> DayStyle {
        DayStyle(status: stores.progress.days[AppCalendar.key(date)],
                 isToday: AppCalendar.calendar.isDateInToday(date))
    }
}
