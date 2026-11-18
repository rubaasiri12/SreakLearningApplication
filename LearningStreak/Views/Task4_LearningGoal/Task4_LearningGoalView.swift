import SwiftUI

// VIEW — Task 4: Change Learning goal
// Activity Page → Learning goal icon → Change learning goal / duration → Activity Page
// Designs: Update goal · Update goal (keyboard) · Update goal (Alert)
// Only DRAWS. LearningGoalViewModel decides when to show the alert.

struct LearningGoalView: View {
    @StateObject private var viewModel: LearningGoalViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTyping: Bool

    init(stores: AppStores) {
        _viewModel = StateObject(wrappedValue: LearningGoalViewModel(stores: stores))
    }

    var body: some View {
        VStack(alignment: .leading) {
            GoalFormFields(
                topicLabel: viewModel.topicLabel,
                topicPlaceholder: viewModel.topicPlaceholder,
                durationLabel: viewModel.durationLabel,
                topic: $viewModel.topic,
                durations: viewModel.durations,
                isSelected: viewModel.isSelected,
                onSelect: viewModel.select,
                focused: $isTyping
            )
            .padding(.top, 24)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isTyping = false
                    if viewModel.checkmarkTapped() { dismiss() }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(.appOrange)
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showUpdateAlert) {
            Button(viewModel.dismissTitle, role: .cancel) { }
            Button(viewModel.updateTitle) {
                viewModel.confirmUpdate()      // streak starts over
                dismiss()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

#Preview("Task 4 – Update goal") {
    NavigationStack { LearningGoalView(stores: .preview(learned: 3)) }
        .preferredColorScheme(.dark)
}
