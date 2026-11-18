import SwiftUI

// VIEW — Task 2: Log a day as learned or freezed
// Activity Page → (Learned Today | Freeze Day) → Activity Page
// States: Current day default · Learned today · Freezed today · No Freezes available
// When the goal ends, the bottom part becomes Task 3 (completed / not met).
// Only DRAWS. Every rule is in ActivityViewModel.

struct ActivityView: View {
    @StateObject private var viewModel: ActivityViewModel
    @Environment(\.scenePhase) private var scenePhase
    private let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    init(stores: AppStores) {
        _viewModel = StateObject(wrappedValue: ActivityViewModel(stores: stores))
    }

    var body: some View {
        VStack(spacing: 20) {
            header
            weekStrip
            streakCards

            Spacer(minLength: 0)

            switch viewModel.goalStatus {
            case .active:
                logButtons                                   // Task 2
            case .completed, .missed:
                GoalFinishedView(                            // Task 3
                    icon: viewModel.finishedIcon,
                    title: viewModel.finishedTitle,
                    subtitle: viewModel.finishedSubtitle,
                    buttonTitle: viewModel.setGoalTitle
                )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .animation(.snappy, value: viewModel.isLearnedToday)
        .animation(.snappy, value: viewModel.isFreezedToday)
        .animation(.snappy, value: viewModel.goalStatus)
        // Keep "today" and the 32-hour rule up to date
        .onAppear { viewModel.refresh() }
        .onReceive(minuteTimer) { _ in viewModel.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            DispatchQueue.main.async { viewModel.refresh() }   // 12 AM → new day
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.refresh() }
        }
    }

    // MARK: Header — "Activity", date, calendar (Task 5) + goal (Task 4) icons

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                Text(viewModel.dateText)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondaryText)
            }
            Spacer()
            HStack(spacing: 8) {
                NavigationLink(value: Route.calendar) { CircleIcon(systemName: "calendar") }
                NavigationLink(value: Route.learningGoal) { CircleIcon(systemName: "pencil.and.outline") }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.top, 8)
    }

    // MARK: Week strip — S M T W T F S

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(viewModel.weekdayLetter(day))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.primaryText)
                    DayCircle(number: viewModel.dayNumber(day), style: viewModel.dayStyle(day), size: 44)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Streak cards — "4 days Learned" / "0 days Freezed"

    private var streakCards: some View {
        HStack(spacing: 14) {
            StatCard(icon: "flame.fill", iconColor: .appOrange,
                     value: viewModel.learnedText, label: viewModel.learnedLabel)
            StatCard(icon: "snowflake", iconColor: .freezeBlue,
                     value: viewModel.freezedText, label: viewModel.freezedLabel)
        }
    }

    // MARK: Log circle + Freeze button (toggle)

    private var logButtons: some View {
        VStack(spacing: 28) {
            // Big circle: orange "Log as Learned" ⇄ grey "Logged as Learned"
            Button {
                withAnimation(.snappy) { viewModel.logTapped() }
            } label: {
                Text(viewModel.circleTitle)
                    .font(.system(size: viewModel.isLearnedToday ? 17 : 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(viewModel.isLearnedToday ? Color.disabledText : Color.primaryText)
                    .padding(36)
                    .frame(width: 274, height: 274)
                    .background(Circle().fill(viewModel.isLearnedToday ? Color.loggedCircle : Color.appOrange))
                    .overlay(Circle().stroke(viewModel.isLearnedToday ? Color.loggedCircleBorder : Color.clear, lineWidth: 1))
                    .shadow(color: viewModel.isLearnedToday ? .clear : Color.orangeGlow, radius: 24)
            }
            .buttonStyle(PressStyle())

            VStack(spacing: 10) {
                // Freeze: blue "Freeze for a day" ⇄ grey "Freezed for a day"
                Button {
                    withAnimation(.snappy) { viewModel.freezeTapped() }
                } label: {
                    Text(viewModel.freezeTitle)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(viewModel.freezeButtonIsBlue ? Color.primaryText : Color.disabledText)
                        .frame(width: 274, height: 48)
                        .background(Capsule().fill(viewModel.freezeButtonIsBlue ? Color.freezeBlue : Color.clear))
                        .glassBackground(Capsule(), tint: viewModel.freezeButtonIsBlue ? .freezeBlue : nil)
                }
                .buttonStyle(PressStyle())
                .disabled(!viewModel.canFreeze)

                Text(viewModel.freezesUsedText)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondaryText)
            }
        }
    }
}

// MARK: - Stat card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primaryText)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color.cardText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .glassBackground(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

// MARK: - Previews (press ▶ Live on the canvas to tap)

#Preview("Task 2 – Current day default") {
    NavigationStack { ActivityView(stores: .preview(learned: 4)) }
        .preferredColorScheme(.dark)
}

#Preview("Task 2 – Learned today") {
    NavigationStack { ActivityView(stores: .preview(learned: 5, today: .learned)) }
        .preferredColorScheme(.dark)
}

#Preview("Task 2 – Freezed today") {
    NavigationStack { ActivityView(stores: .preview(learned: 4, freezed: 1, today: .freezed)) }
        .preferredColorScheme(.dark)
}

#Preview("Task 2 – No Freezes available") {
    NavigationStack { ActivityView(stores: .preview(learned: 3, freezed: 2)) }
        .preferredColorScheme(.dark)
}

#Preview("Task 2 – New goal (0 days)") {
    NavigationStack { ActivityView(stores: .preview()) }
        .preferredColorScheme(.dark)
}
