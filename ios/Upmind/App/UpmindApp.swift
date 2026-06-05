import SwiftUI

@main
struct UpmindApp: App {
    init() {
        PostHogManager.shared.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
