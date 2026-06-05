import Foundation
import Observation
import SwiftData

enum AppFlow: Equatable {
    case loading
    case anonymous
    case onboarding
    case signedIn(userId: String)
}

@MainActor
@Observable
final class AppCoordinator {
    var flow: AppFlow = .loading

    let syncWorker: SyncWorker
    let modelContext: ModelContext

    private let authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
        self.syncWorker = SyncWorker(
            userIdProvider: { [weak authStore] in
                guard case .signedIn(let userId, _) = authStore?.state else { return nil }
                return userId
            }
        )
        self.modelContext = ModelContext(SwiftDataStack.container)
    }

    func bootstrap() async {
        await authStore.bootstrap()
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

    func recordSession(_ result: SessionResult) async {
        let userId: String
        switch authStore.state {
        case .signedIn(let id, _): userId = id
        default: userId = "anonymous"
        }
        await syncWorker.enqueue(
            result,
            modelContext: modelContext,
            userIdentifier: userId
        )
    }
}
