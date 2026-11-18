import SwiftUI
import UIKit

// VIEW COMPONENT — Apple's default calendar (UICalendarView) with our marks
//   • Learned days → filled orange circle (Apple's multi-date selection, locked = view only)
//   • Freezed days → Apple's standard dot under the number, in blue
//   • Today        → Apple's default today style, in orange
//   • Swipe left / right to change month; future days are greyed out
// UIViewRepresentable = a wrapper that lets a UIKit view live inside SwiftUI.

struct AppleCalendarView: UIViewRepresentable {
    let learnedDates: [Date]
    let freezedDates: [Date]
    let styleFor: (Date) -> DayStyle

    // 1. Create Apple's calendar once
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = AppCalendar.calendar                  // Gregorian, week starts Sunday
        calendarView.locale = Locale(identifier: "en_US")
        calendarView.tintColor = UIColor(Color.appOrange)              // orange circles + today
        calendarView.availableDateRange = DateInterval(start: .distantPast, end: Date())  // no future
        calendarView.wantsDateDecorations = true
        calendarView.delegate = context.coordinator                    // decides the blue dots

        // Keep Apple's normal shape inside SwiftUI (stops it being squeezed or cut off)
        calendarView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        calendarView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        // Multi-date selection = Apple draws filled circles on the chosen days
        let selection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        context.coordinator.selection = selection
        return calendarView
    }

    // 2. Every time SwiftUI updates: put the marks on the right days
    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        context.coordinator.styleFor = styleFor
        context.coordinator.selection?.setSelectedDates(learnedDates.map(Self.components), animated: false)

        let changed = (learnedDates + freezedDates).map(Self.components)
        if !changed.isEmpty {
            calendarView.reloadDecorations(forDateComponents: changed, animated: false)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(styleFor: styleFor) }

    /// Date → the year/month/day pieces Apple's calendar works with.
    static func components(_ date: Date) -> DateComponents {
        AppCalendar.calendar.dateComponents([.calendar, .era, .year, .month, .day], from: date)
    }

    // MARK: - Coordinator: answers Apple's questions

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionMultiDateDelegate {
        var styleFor: (Date) -> DayStyle
        weak var selection: UICalendarSelectionMultiDate?

        init(styleFor: @escaping (Date) -> DayStyle) {
            self.styleFor = styleFor
        }

        // "What goes under this day?" → Apple's standard dot, in blue, for freezed days
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
            guard let date = AppCalendar.calendar.date(from: dateComponents),
                  styleFor(date) == .freezed else { return nil }
            return .default(color: UIColor(Color.freezeBlue), size: .large)
        }

        // View only: the user can't select or deselect days
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                                canSelectDate dateComponents: DateComponents) -> Bool { false }
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                                canDeselectDate dateComponents: DateComponents) -> Bool { false }
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                                didSelectDate dateComponents: DateComponents) { }
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate,
                                didDeselectDate dateComponents: DateComponents) { }
    }
}
