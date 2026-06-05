import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var style: Style = .solid
    @Environment(\.theme) private var theme

    enum Style { case solid, gradient, ghost }

    init(_ title: String, icon: String? = nil, style: Style = .solid, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon { Image(systemName: icon) }
                Text(title)
            }
            .font(.title3).bold()
            .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
            .foregroundStyle(.white)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .shadow(
                color: theme.accentPrimary.opacity(style == .ghost ? 0 : 0.3),
                radius: 12, x: 0, y: 6
            )
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .solid:
            theme.accentPrimary
        case .gradient:
            LinearGradient(
                colors: [theme.accentPrimary, theme.accentPrimary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ghost:
            theme.surfaceElevated
        }
    }
}
