import SwiftUI

struct GameCatalogView: View {
    @State private var vm = GameCatalogViewModel()
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
                            NavigationLink(value: game) {
                                GameCard(game: game)
                            }
                            .buttonStyle(.plain)
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
    }

    private var searchField: some View {
        TextField("Search games", text: $vm.searchText)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
    }
}
