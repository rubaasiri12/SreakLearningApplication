import SwiftUI

// VIEW — Task 1: Start learning!
// Onboarding → Set learning goal and duration → Activity Page
// Only DRAWS. Every text, value and action comes from OnboardingViewModel.

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @FocusState private var isTyping: Bool

    init(stores: AppStores) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(stores: stores))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            flame
            greeting

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

            Spacer()
            startButton
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.appBackground.ignoresSafeArea())
        .contentShape(Rectangle())
        .onTapGesture { isTyping = false }   // tap outside → hide keyboard
    }

    // MARK: Flame (no circle)

    private var flame: some View {
        Image(systemName: "flame.fill")
            .font(.system(size: 36))
            .foregroundStyle(Color.appOrange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
    }

    // MARK: Hello Learner

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(viewModel.titleRegular)
                Text(viewModel.titleBold).bold()
            }
            .font(.system(size: 34))
            .foregroundStyle(Color.primaryText)

            Text(viewModel.subtitle)
                .font(.system(size: 17))
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.bottom, 32)
    }

    // MARK: Start Learning

    private var startButton: some View {
        VStack(spacing: 10) {
            Button(viewModel.startButtonTitle) {
                isTyping = false
                viewModel.startLearning()
            }
            .buttonStyle(OrangeCapsuleStyle(width: 182))

            Text(viewModel.footnote)
                .font(.system(size: 13))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 16)
    }
}

#Preview("Task 1 – Onboarding") {
    OnboardingView(stores: .preview(onboarded: false))
        .preferredColorScheme(.dark)
}
