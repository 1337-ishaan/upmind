import SwiftUI

@main
struct UpmindApp: App {
    init() {
        PostHogManager.shared.bootstrap()
        RevenueCatManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
