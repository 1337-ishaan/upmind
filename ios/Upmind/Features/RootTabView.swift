import SwiftUI
import SwiftData

struct RootTabView: View {
    let modelContext: ModelContext
    let syncWorker: SyncWorker
    let authStore: AuthStore
    let onSessionFinished: (SessionResult) -> Void
    @Environment(\.theme) private var theme

    @State private var selectedTab: Int = 0
    @State private var showPaywall: Bool = false
    @State private var pendingGame: GameDef?

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(modelContext: modelContext, syncWorker: syncWorker) { game in
                attempt(game)
            }
            .tabItem { Label("Today", systemImage: "sun.max.fill") }
            .tag(0)

            GameCatalogView(onSessionFinished: onSessionFinished)
                .tabItem { Label("Games", systemImage: "square.grid.2x2.fill") }
                .tag(1)

            LeaderboardView(syncWorker: syncWorker)
                .tabItem { Label("Leaderboard", systemImage: "list.number") }
                .tag(2)

            ProfileView(
                authStore: authStore,
                syncWorker: syncWorker
            )
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(3)
        }
        .tint(theme.accentPrimary)
        .sheet(isPresented: $showPaywall) {
            PaywallView(onPurchased: {
                if let g = pendingGame {
                    pendingGame = g
                    showPaywall = true  // dismiss then re-present after purchase
                }
            })
        }
    }

    private func attempt(_ game: GameDef) {
        if game.isPremium && !RevenueCatManager.shared.isPremium {
            pendingGame = game
            showPaywall = true
        } else {
            selectedTab = 1  // switch to Games tab
        }
    }
}
