import Foundation
import Observation

enum AppFlow: Equatable {
    case loading
    case anonymous           // never signed in, no onboarding yet
    case onboarding
    case signedIn(userId: String)
}

@MainActor
@Observable
final class AppCoordinator {
    var flow: AppFlow = .loading

    private let authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
    }

    func bootstrap() async {
        await authStore.bootstrap()
        // For Plan 3 R1, we skip onboarding and go straight to the main app
        // for both anonymous and signed-in users. R7 will add the onboarding flow.
        switch authStore.state {
        case .loading: flow = .loading
        case .anonymous: flow = .anonymous
        case .signedIn(_, _): flow = .signedIn(userId: "")
        case .error: flow = .anonymous
        }
    }

    func handleAuthChange() {
        switch authStore.state {
        case .signedIn(let userId, _): flow = .signedIn(userId: userId)
        case .anonymous, .error: flow = .anonymous
        case .loading: flow = .loading
        }
    }
}
