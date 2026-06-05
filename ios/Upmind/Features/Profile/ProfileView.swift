import SwiftUI

struct ProfileView: View {
    let authStore: AuthStore
    let syncWorker: SyncWorker
    let pendingCountProvider: () -> Int
    @Environment(\.theme) private var theme

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.lg) {
                Text("Profile (R6 stub)")
                    .foregroundStyle(theme.textSecondary)
            }
            .navigationTitle("Profile")
        }
    }
}
