import SwiftUI

// VIEW — Task 5: Open Calendar to see all previous learned days
// Activity Page → Calendar icon → Calendar Page
// Custom calendar like the design: months scroll down, filled circles —
// orange = learned, blue = freezed, solid orange = today. View only.
// ONLY drawing here; CalendarViewModel prepares the months and the styles.

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    init(stores: AppStores) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(stores: stores))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.months, id: \.self) { month in
                        monthSection(month)
                            .id(month)
                        Rectangle()                       // line between months
                            .fill(Color.divider)
                            .frame(height: 0.5)
                    }
                }
                .padding(16)
            }
            .onAppear {
                if let current = viewModel.currentMonth { proxy.scrollTo(current, anchor: .top) }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.pageTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: One month — "January 2026", SUN MON ..., day circles

    private func monthSection(_ month: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.monthTitle(month))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primaryText)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondaryText)
                }
                ForEach(Array(viewModel.grid(for: month).enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCircle(number: viewModel.dayNumber(date), style: viewModel.dayStyle(date), size: 40)
                    } else {
                        Color.clear.frame(height: 40)     // empty slot before day 1
                    }
                }
            }
        }
        .allowsHitTesting(false)   // view only
    }
}

#Preview("Task 5 – Activities calendar") {
    NavigationStack { CalendarView(stores: .preview(learned: 25, freezed: 4, duration: .month)) }
        .preferredColorScheme(.dark)
}
