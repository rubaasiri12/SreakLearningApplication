import Foundation
import Combine

// VIEWMODEL — Task 5: Open Calendar to see all previous learned days
// Gives Apple's calendar the learned and freezed days (from the SwiftData StorageDB).
// View only — nothing to tap.

final class CalendarViewModel: ObservableObject {

    let pageTitle = "Activities"
    let learnedLegend = "Learned"
    let freezedLegend = "Freezed"

    private let stores: AppStores
    private var cancellables = Set<AnyCancellable>()

    init(stores: AppStores) {
        self.stores = stores
        stores.progress.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    /// Every Learned day → orange filled circles.
    var learnedDates: [Date] { dates(of: .learned) }

    /// Every Freezed day → blue dot under the number.
    var freezedDates: [Date] { dates(of: .freezed) }

    func dayStyle(_ date: Date) -> DayStyle {
        DayStyle(status: stores.progress.days[AppCalendar.key(date)],
                 isToday: AppCalendar.calendar.isDateInToday(date))
    }

    private func dates(of kind: DayStatus) -> [Date] {
        stores.progress.days
            .filter { $0.value == kind }
            .compactMap { AppCalendar.keyFormatter.date(from: $0.key) }
            .sorted()
    }
}
