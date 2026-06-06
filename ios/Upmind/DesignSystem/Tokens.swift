import SwiftUI

// MARK: - Spacing

enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Radii

enum Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 22
    static let pill: CGFloat = 999
}

// MARK: - HIG tap-target

enum MinTapTarget {
    /// HIG minimum for iOS touch targets.
    static let size: CGFloat = 44
}

// MARK: - Motion

enum Motion {
    static let pageTransition: Animation = .easeInOut(duration: 0.48)
    static let cardPress: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let countUp: Animation = .easeInOut(duration: 0.6)
    static let answerFlash: Animation = .easeInOut(duration: 0.18)
    static let answerAdvance: TimeInterval = 0.6
}

// MARK: - Colors

struct ColorTokens: Sendable {
    let surfaceBase: Color
    let surfaceElevated: Color
    let accentPrimary: Color
    let accentSoft: Color
    let textPrimary: Color
    let textSecondary: Color
    let strokeSubtle: Color
    let success: Color
    let warning: Color
    let error: Color

    /// Exposed for tests so we can assert the source of truth.
    let accentPrimaryHex: String

    static let light = ColorTokens(
        surfaceBase: Color(hex: "F5F0E8"),       // warm off-white
        surfaceElevated: Color(hex: "FFFFFF"),
        accentPrimary: Color(hex: "14B8A6"),    // teal
        accentSoft: Color(hex: "5EEAD4"),
        textPrimary: Color(hex: "0A0F1C"),
        textSecondary: Color(hex: "6B6258"),
        strokeSubtle: Color(hex: "E0D8CC"),
        success: Color(hex: "10B981"),
        warning: Color(hex: "F59E0B"),
        error: Color(hex: "EF4444"),
        accentPrimaryHex: "14B8A6"
    )

    static let dark = ColorTokens(
        surfaceBase: Color(hex: "0A0F1C"),       // deep navy
        surfaceElevated: Color(hex: "0F172A"),
        accentPrimary: Color(hex: "14B8A6"),    // teal
        accentSoft: Color(hex: "5EEAD4"),
        textPrimary: Color(hex: "F5F0E8"),
        textSecondary: Color(hex: "94A3B8"),
        strokeSubtle: Color(hex: "1E293B"),
        success: Color(hex: "34D399"),
        warning: Color(hex: "FBBF24"),
        error: Color(hex: "F87171"),
        accentPrimaryHex: "14B8A6"
    )
}

extension Color {
    /// Hex initializer. Supports 6-char hex strings; 8-char (with alpha) optional.
    init(hex: String) {
        var s = hex.uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt64(s, radix: 16) else {
            self = .black
            return
        }
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}

// MARK: - Gradients

enum GradientTokens {
    /// Hero gradient for the paywall + welcome screens — deep navy fading to
    /// a faint teal wash in the bottom-right corner.
    static let hero = LinearGradient(
        colors: [Color(hex: "0F172A"), Color(hex: "0A0F1C"), Color(hex: "14B8A6").opacity(0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Card accent for the primary brand mark (logo, hero icon, streak ring).
    static let cardAccent = LinearGradient(
        colors: [Color(hex: "14B8A6"), Color(hex: "5EEAD4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Warm accent used for the "PRO" pill on premium games.
    static let proAccent = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "FBBF24")],
        startPoint: .leading,
        endPoint: .trailing
    )
}
