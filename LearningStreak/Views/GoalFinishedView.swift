import SwiftUI

// VIEW — Task 3: Set new / same goal when the goal ends
// Activity Page → Set a goal → Learning Goal page → Activity Page
//   completed → "Well done!  Ready for your next goal?"
//   missed    → "You didn't reach your goal this time.  Want to set another goal?"
// Texts come from ActivityViewModel. "Set a goal" opens the Learning Goal page
// filled with the old goal: tap ✓ to keep it, or change it for a new one.

struct GoalFinishedView: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Color.appOrange)

            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.primaryText)
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondaryText)
            }
            .multilineTextAlignment(.center)

            NavigationLink(value: Route.learningGoal) {
                Label(buttonTitle, systemImage: "arrow.clockwise.circle")
            }
            .buttonStyle(OrangeCapsuleStyle(height: 44))
            .padding(.top, 18)
        }
        .padding(.horizontal, 24)
    }
}

#Preview("Task 3 – Goal completed") {
    NavigationStack { ActivityView(stores: .preview(learned: 5, freezed: 2, status: .completed)) }
        .preferredColorScheme(.dark)
}

#Preview("Task 3 – Goal not met") {
    NavigationStack { ActivityView(stores: .preview(learned: 2, freezed: 1, status: .missed)) }
        .preferredColorScheme(.dark)
}
