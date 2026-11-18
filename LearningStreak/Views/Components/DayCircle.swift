import SwiftUI

// VIEW COMPONENT
// One day number in a circle (Task 2 week strip).
// The ViewModel decides the style; this file turns the style into colors.

struct DayCircle: View {
    let number: String
    let style: DayStyle
    var size: CGFloat = 44

    var body: some View {
        Text(number)
            .font(.system(size: size * 0.5, weight: style == .today ? .bold : .medium))
            .foregroundStyle(textColor)
            .frame(width: size, height: size)
            .background(Circle().fill(fillColor))
    }

    private var textColor: Color {
        switch style {
        case .learned: return .appOrange
        case .freezed: return .freezeBlue
        case .today, .normal: return .primaryText
        }
    }

    private var fillColor: Color {
        switch style {
        case .learned: return .learnedTint
        case .freezed: return .freezedTint
        case .today: return .appOrange
        case .normal: return .clear
        }
    }
}

#Preview("Day circles") {
    HStack {
        DayCircle(number: "20", style: .learned)
        DayCircle(number: "21", style: .freezed)
        DayCircle(number: "22", style: .today)
        DayCircle(number: "23", style: .normal)
    }
    .padding()
    .background(Color.appBackground)
}
