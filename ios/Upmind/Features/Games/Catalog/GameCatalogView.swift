import SwiftUI

/// Stub catalog for Round 1. Lists all 42 games by name. Tap to launch
/// the player. Round 3 replaces this with a 2-column grid + construct
/// filter chips.
struct GameCatalogView: View {
    private let games = Games.all
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            List {
                ForEach(games) { game in
                    NavigationLink(value: game) {
                        HStack {
                            Text(game.name)
                                .foregroundStyle(theme.textPrimary)
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
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Games")
            .navigationDestination(for: GameDef.self) { game in
                GamePlayerView(game: game)
            }
        }
    }
}
