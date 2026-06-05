import SwiftUI

struct RootView: View {
    @State private var authStore: AuthStore
    @State private var coordinator: AppCoordinator
    @State private var hasLoggedAppOpen: Bool = false
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
            if !hasLoggedAppOpen {
                hasLoggedAppOpen = true
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
                let firstLaunch = !UserDefaults.standard.bool(forKey: "Upmind.HasLaunched")
                UserDefaults.standard.set(true, forKey: "Upmind.HasLaunched")
                PostHogManager.shared.track(.appOpened(isFirstLaunch: firstLaunch, appVersion: version))
            }
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
                authStore: authStore,
                onSessionFinished: { result in
                    Task { await coordinator.recordSession(result) }
                }
            )
        case .onboarding:
            OnboardingFlowView(onComplete: { coordinator.onboardingComplete() })
        }
    }
}
