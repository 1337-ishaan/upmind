import SwiftUI

/// Large display-style title used on Welcome, Onboarding, and Result screens.
struct HeroText: View {
    let text: String
    @Environment(\.theme) private var theme

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(theme.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
    }
}

/// Secondary copy under a hero title.
struct SubtitleText: View {
    let text: String
    @Environment(\.theme) private var theme

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.title3)
            .foregroundStyle(theme.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
    }
}
