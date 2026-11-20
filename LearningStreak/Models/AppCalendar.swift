import Foundation

// MODEL HELPER
// Date rules for the app's data. Fixed Gregorian calendar (week starts Sunday,
// English names) so the app matches the design whatever the phone's settings are.

enum AppCalendar {
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1   // Sunday
        cal.locale = Locale(identifier: "en_US")
        cal.timeZone = .current
        return cal
    }()

    static let keyFormatter = makeFormatter("yyyy-MM-dd", posix: true)
    static let fullDateFormatter = makeFormatter("EEEE, d MMMM")   // Thursday, 24 October
    static let dayNumberFormatter = makeFormatter("d")             // 24

    /// "2026-11-18" — one label per day.
    static func key(_ date: Date) -> String { keyFormatter.string(from: date) }

    static func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }

    /// "S", "M", "T", ... (Activity page)
    static var letterWeekdays: [String] { calendar.veryShortWeekdaySymbols }

    /// The 7 days (Sunday → Saturday) of the week that contains `date`.
    static func daysOfWeek(containing date: Date) -> [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? startOfDay(date)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private static func makeFormatter(_ format: String, posix: Bool = false) -> DateFormatter {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = Locale(identifier: posix ? "en_US_POSIX" : "en_US")
        f.timeZone = calendar.timeZone
        f.dateFormat = format
        return f
    }
}
