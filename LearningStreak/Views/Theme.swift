import SwiftUI

// VIEW — THEME
// Every color and shared style. Change a color once, it changes everywhere.

// MARK: - Colors

extension Color {
    // Main colors
    static let appOrange          = Color(hex: "FF9230")
    static let freezeBlue         = Color(hex: "3CD3FE")

    // Backgrounds
    static let appBackground      = Color(hex: "000000")
    static let loggedCircle       = Color(hex: "1A1A1A")                 // "Logged as Learned" circle
    static let learnedTint        = Color.appOrange.opacity(0.20)        // learned days
    static let freezedTint        = Color.freezeBlue.opacity(0.20)       // freezed days

    // Text
    static let primaryText        = Color(hex: "FFFFFF")
    static let cardText           = Color(hex: "FFFFFF").opacity(0.85)   // "Learned" / "Freezed" labels
    static let secondaryText      = Color(hex: "8C8C8C")                 // date, captions
    static let disabledText       = Color(hex: "616161")                 // greyed-out buttons

    // Lines and effects
    static let inputLine          = Color(hex: "FFFFFF").opacity(0.20)   // line under the text field
    static let loggedCircleBorder = Color(hex: "FFFFFF").opacity(0.15)
    static let orangeGlow         = Color.appOrange.opacity(0.35)        // shadow under the big circle

    // Glass (used before iOS 26)
    static let glassFill          = Color(hex: "FFFFFF").opacity(0.06)
    static let glassEdgeLight     = Color(hex: "FFFFFF").opacity(0.35)
    static let glassEdgeDim       = Color(hex: "FFFFFF").opacity(0.05)
    static let glassEdgeMid       = Color(hex: "FFFFFF").opacity(0.25)
}

extension Color {
    /// Write colors as hex codes: Color(hex: "FF9230")
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let value = UInt64(cleaned, radix: 16) ?? 0
        self.init(red: Double((value >> 16) & 0xFF) / 255,
                  green: Double((value >> 8) & 0xFF) / 255,
                  blue: Double(value & 0xFF) / 255)
    }
}

// MARK: - Glass background

extension View {
    /// Liquid Glass on iOS 26 (Xcode 26+); a dark glassy look with a light edge otherwise.
    @ViewBuilder
    func glassBackground<S: Shape>(_ shape: S, tint: Color? = nil) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(tint.map { Glass.regular.tint($0) } ?? .regular, in: shape)
        } else {
            self.fallbackGlass(shape, tint: tint)
        }
        #else
        self.fallbackGlass(shape, tint: tint)
        #endif
    }

    private func fallbackGlass<S: Shape>(_ shape: S, tint: Color?) -> some View {
        self
            .background(shape.fill(tint ?? Color.glassFill))
            .overlay(
                shape.stroke(
                    LinearGradient(colors: [Color.glassEdgeLight, Color.glassEdgeDim, Color.glassEdgeMid],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 0.8)
            )
    }
}

// MARK: - Buttons

/// Full-orange capsule ("Start Learning", "Set a goal").
struct OrangeCapsuleStyle: ButtonStyle {
    var width: CGFloat? = nil
    var height: CGFloat = 48

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color.primaryText)
            .padding(.horizontal, 24)
            .frame(width: width, height: height)
            .background(Capsule().fill(Color.appOrange))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }
}

/// Small press-down effect for the big circle and the Freeze button.
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy, value: configuration.isPressed)
    }
}

/// Round glass icon (calendar / pencil in the Activity header).
struct CircleIcon: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 22, weight: .medium))
            .foregroundStyle(Color.primaryText)
            .frame(width: 52, height: 52)
            .glassBackground(Circle())
    }
}
