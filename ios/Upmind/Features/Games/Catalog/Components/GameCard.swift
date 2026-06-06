import SwiftUI

/// One tile in the 2-column catalog grid. Shows the construct icon, a
/// PRO pill for premium games, the name, a one-line description, and the
/// trial count. The card is purely presentational — tap handling lives
/// on the parent (a `NavigationLink` or a `Button` for premium gating).
struct GameCard: View {
    let game: GameDef
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                constructIcon
                Spacer()
                if game.isPremium {
                    Text("PRO")
                        .font(.caption2).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(GradientTokens.proAccent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer().frame(height: Spacing.xs)
            Text(game.name)
                .font(.headline)
                .foregroundStyle(theme.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(game.description)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: Spacing.xs) {
                Image(systemName: "rectangle.stack")
                    .font(.caption2)
                Text("\(game.trials)")
                    .font(.caption2).bold()
            }
            .foregroundStyle(theme.textSecondary)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Radius.lg)
                .fill(theme.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.accentPrimary.opacity(0.4),
                            theme.strokeSubtle.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }

    private var constructIcon: some View {
        let (symbol, color) = constructIconInfo
        return Image(systemName: symbol)
            .font(.title3)
            .foregroundStyle(color)
            .frame(width: 36, height: 36)
            .background(color.opacity(0.15))
            .clipShape(Circle())
    }

    /// Per-construct SF Symbol + color. Kept as a tuple-returning computed
    /// property so the `body` stays declarative; the colors are stable
    /// across schemes so we don't need a theme lookup here.
    private var constructIconInfo: (String, Color) {
        switch game.construct {
        case .attention:  return ("eye.fill", Color(hex: "6366F1"))
        case .memory:     return ("brain.head.profile", Color(hex: "8B5CF6"))
        case .processing: return ("bolt.fill", Color(hex: "F59E0B"))
        case .numeracy:   return ("function", Color(hex: "10B981"))
        case .verbal:     return ("text.bubble.fill", Color(hex: "3B82F6"))
        case .problem:    return ("puzzlepiece.fill", Color(hex: "EC4899"))
        case .executive:  return ("crown.fill", Color(hex: "F59E0B"))
        }
    }
}
