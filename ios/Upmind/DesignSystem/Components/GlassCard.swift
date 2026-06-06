import SwiftUI

/// A glass-effect card for prominent surfaces. Uses a layered approach
/// (base fill + soft gradient + subtle border + shadow) that approximates
/// iOS 26's `.glassEffect()` while staying safe across the iOS 26 SDK and
/// the snapshot test target.
struct GlassCard<Content: View>: View {
    let content: () -> Content
    let padding: CGFloat
    @Environment(\.theme) private var theme

    init(padding: CGFloat = Spacing.lg, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.padding = padding
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .fill(theme.surfaceElevated)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.clear,
                                theme.accentPrimary.opacity(0.04),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg)
                    .stroke(theme.strokeSubtle.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
