import SwiftUI

/// One tile in the 2-column catalog grid. Shows the game name, a short
/// description, the construct tag, the trial count, and a "PRO" pill for
/// premium-gated games. The card is purely presentational — tap handling
/// lives on the parent (a `NavigationLink`).
struct GameCard: View {
    let game: GameDef
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(game.name)
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                    .lineLimit(2)
                Spacer()
                if game.isPremium {
                    Text("PRO")
                        .font(.caption2).bold()
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(theme.accentPrimary.opacity(0.2))
                        .foregroundStyle(theme.accentPrimary)
                        .clipShape(Capsule())
                }
            }
            Text(game.description)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
                .lineLimit(2)
            HStack {
                Text(game.construct.label)
                    .font(.caption2)
                    .foregroundStyle(theme.accentPrimary)
                Spacer()
                Text("\(game.trials) trials")
                    .font(.caption2)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md)
                .stroke(theme.strokeSubtle, lineWidth: 1)
        )
    }
}
