import SwiftUI

// VIEW COMPONENT
// "I want to learn" + "I want to learn it in a" Week / Month / Year.
// Shared by Task 1 (Onboarding) and Task 4 (Learning Goal).
// It only draws; texts, values and actions come from the screen's ViewModel.

struct GoalFormFields: View {
    let topicLabel: String
    let topicPlaceholder: String
    let durationLabel: String
    @Binding var topic: String
    let durations: [GoalDuration]
    let isSelected: (GoalDuration) -> Bool
    let onSelect: (GoalDuration) -> Void
    var focused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // I want to learn
            VStack(alignment: .leading, spacing: 6) {
                Text(topicLabel)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.primaryText)

                TextField(topicPlaceholder, text: $topic)
                    .font(.system(size: 17))
                    .foregroundStyle(Color.primaryText)
                    .focused(focused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .padding(.vertical, 8)

                Rectangle()
                    .fill(Color.inputLine)
                    .frame(height: 0.5)
            }

            // I want to learn it in a
            VStack(alignment: .leading, spacing: 12) {
                Text(durationLabel)
                    .font(.system(size: 22))
                    .foregroundStyle(Color.primaryText)

                HStack(spacing: 8) {
                    ForEach(durations) { duration in
                        DurationChip(title: duration.title, isSelected: isSelected(duration)) {
                            withAnimation(.snappy) { onSelect(duration) }
                        }
                    }
                }
            }
        }
    }
}

/// One chip: Week / Month / Year.
struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.primaryText : Color.secondaryText)
                .frame(width: 97, height: 48)
                .background(Capsule().fill(isSelected ? Color.appOrange : Color.clear))
                .glassBackground(Capsule(), tint: isSelected ? .appOrange : nil)
        }
        .buttonStyle(.plain)
    }
}
