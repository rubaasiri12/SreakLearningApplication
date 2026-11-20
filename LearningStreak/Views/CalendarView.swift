import SwiftUI

// VIEW — Task 5: Open Calendar to see all previous learned days
// Activity Page → Calendar icon → Calendar Page
// Apple's default calendar (AppleCalendarView.swift): orange circle = learned, blue dot = freezed.
// View only. CalendarViewModel gives the days; this file only draws.

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel

    init(stores: AppStores) {
        _viewModel = StateObject(wrappedValue: CalendarViewModel(stores: stores))
    }

    var body: some View {
        VStack(spacing: 20) {
            AppleCalendarView(
                learnedDates: viewModel.learnedDates,
                freezedDates: viewModel.freezedDates,
                styleFor: viewModel.dayStyle
            )

            legend
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.pageTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Legend — what the marks mean

    private var legend: some View {
        HStack(spacing: 24) {
            HStack(spacing: 8) {
                Circle().fill(Color.appOrange).frame(width: 18, height: 18)
                Text(viewModel.learnedLegend)
            }
            HStack(spacing: 8) {
                Circle().fill(Color.freezeBlue).frame(width: 8, height: 8)
                    .frame(width: 18, height: 18)
                Text(viewModel.freezedLegend)
            }
        }
        .font(.system(size: 15))
        .foregroundStyle(Color.secondaryText)
    }
}

#Preview("Task 5 – Apple calendar") {
    NavigationStack { CalendarView(stores: .preview(learned: 10, freezed: 3, duration: .month)) }
        .preferredColorScheme(.dark)
}
