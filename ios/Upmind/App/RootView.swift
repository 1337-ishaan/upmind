import SwiftUI

struct RootView: View {
    @State private var authStore: AuthStore
    @State private var coordinator: AppCoordinator
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme

    init() {
        let store = AuthStore()
        _authStore = State(wrappedValue: store)
        _coordinator = State(wrappedValue: AppCoordinator(authStore: store))
    }

    var body: some View {
        ZStack {
            theme.surfaceBase.ignoresSafeArea()
            content
        }
        .environment(\.theme, Theme.tokens(for: colorScheme))
        .task {
            await coordinator.bootstrap()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.flow {
        case .loading:
            ProgressView()
                .tint(theme.accentPrimary)
        case .anonymous:
            SignInView(authStore: authStore)
                .onChange(of: authStore.state) { _, _ in
                    coordinator.handleAuthChange()
                }
        case .signedIn:
            RootTabView(
                modelContext: coordinator.modelContext,
                syncWorker: coordinator.syncWorker,
                onSessionFinished: { result in
                    Task { await coordinator.recordSession(result) }
                }
            )
        case .onboarding:
            SignInView(authStore: authStore)
        }
    }
}
