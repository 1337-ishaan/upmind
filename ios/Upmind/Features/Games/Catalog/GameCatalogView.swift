import SwiftUI

struct GameCatalogView: View {
    @State private var vm = GameCatalogViewModel()
    @State private var showPaywall: Bool = false
    @State private var pendingGame: GameDef?
    @Environment(\.theme) private var theme

    let onSessionFinished: (SessionResult) -> Void

    init(onSessionFinished: @escaping (SessionResult) -> Void = { _ in }) {
        self.onSessionFinished = onSessionFinished
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                ConstructFilterChips(selection: $vm.selectedConstruct)
                    .padding(.vertical, Spacing.sm)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.sm) {
                        ForEach(vm.filteredGames) { game in
                            gameCell(game)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .background(theme.surfaceBase)
            .navigationTitle("Games")
            .navigationDestination(for: GameDef.self) { game in
                GamePlayerView(game: game, onSessionFinished: onSessionFinished)
            }
        }
        .sheet(isPresented: $showPaywall, onDismiss: {
            // After dismiss, if user is now premium and a game is pending,
            // re-trigger the navigation by setting a new pending value the
            // user can tap. We just clear it for now — the user can tap again.
            pendingGame = nil
        }) {
            PaywallView(onPurchased: {
                // After a successful purchase, the user can tap the game tile
                // again; the entitlement check on `gameCell` will now pass.
            })
        }
    }

    @ViewBuilder
    private func gameCell(_ game: GameDef) -> some View {
        if game.isPremium && !RevenueCatManager.shared.isPremium {
            Button {
                pendingGame = game
                showPaywall = true
            } label: {
                GameCard(game: game)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: game) {
                GameCard(game: game)
            }
            .buttonStyle(.plain)
        }
    }

    private var searchField: some View {
        TextField("Search games", text: $vm.searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
    }
}
