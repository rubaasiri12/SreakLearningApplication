import SwiftUI

// APP (not part of MVVM)
// Starts the app, creates the three storages once, and picks the first screen.

@main
struct LearningStreakApp: App {
    /// The three storages (SwiftData + AppStorage + UserDefaults), created once.
    private let stores = AppStores.live()

    var body: some Scene {
        WindowGroup {
            RootView(stores: stores)
                .preferredColorScheme(.dark)
                .tint(.appOrange)
        }
    }
}

/// Pages you can open from the Activity page.
enum Route: Hashable {
    case learningGoal   // Task 3 "Set a goal" + Task 4 pencil icon
    case calendar       // Task 5 calendar icon
}

/// Not onboarded yet → Onboarding (Task 1). Onboarded → Activity page (Task 2).
struct RootView: View {
    let stores: AppStores
    /// Watches the UserDefaults state, so the screen switches after "Start Learning".
    @ObservedObject private var state: AppStateDefaults

    init(stores: AppStores) {
        self.stores = stores
        _state = ObservedObject(wrappedValue: stores.state)
    }

    var body: some View {
        Group {
            if !state.hasOnboarded {
                OnboardingView(stores: stores)                                  // Task 1
            } else {
                NavigationStack {
                    ActivityView(stores: stores)                                // Task 2 (+ Task 3)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .learningGoal: LearningGoalView(stores: stores)   // Task 3 / 4
                            case .calendar: CalendarView(stores: stores)           // Task 5
                            }
                        }
                }
            }
        }
        .animation(.easeInOut, value: state.hasOnboarded)
    }
}

#Preview("Full app – from Onboarding") {
    RootView(stores: .preview(onboarded: false))
        .preferredColorScheme(.dark)
        .tint(.appOrange)
}

#Preview("Full app – Activity") {
    RootView(stores: .preview(learned: 4))
        .preferredColorScheme(.dark)
        .tint(.appOrange)
}
