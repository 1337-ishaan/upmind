import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ProfileViewModel {
    var email: String = ""
    var isPremium: Bool = false
    var pendingSyncCount: Int = 0
    var lastSyncError: String?

    let authStore: AuthStore
    let syncWorker: SyncWorker

    init(authStore: AuthStore, syncWorker: SyncWorker) {
        self.authStore = authStore
        self.syncWorker = syncWorker
        refresh()
    }

    func refresh() {
        if case .signedIn(_, let e) = authStore.state {
            email = e ?? ""
        } else {
            email = ""
        }
        isPremium = RevenueCatManager.shared.isPremium
        pendingSyncCount = syncWorker.pendingCount
        lastSyncError = syncWorker.lastError
    }

    func signOut() async {
        await authStore.signOut()
        refresh()
    }
}
