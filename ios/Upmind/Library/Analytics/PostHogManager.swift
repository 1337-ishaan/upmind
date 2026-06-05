import Foundation
import PostHog

/// Thin wrapper over the PostHog iOS SDK.
/// Plan 1 only initializes the SDK. Plan 4 wires up the full event taxonomy,
/// feature flags, and the opt-out toggle in Profile → Privacy.
@MainActor
final class PostHogManager {
    static let shared = PostHogManager()

    private let optInKey = "Upmind.AnalyticsOptIn"

    /// Whether the user has opted in to anonymous usage analytics.
    /// Defaults to true. Flipping the Profile → Privacy toggle calls
    /// `setOptedIn(_:)` which also flushes / clears the SDK queue.
    var isOptedIn: Bool {
        get { UserDefaults.standard.object(forKey: optInKey) as? Bool ?? true }
        set { setOptedIn(newValue) }
    }

    private init() {}

    /// Called once from `UpmindApp.init()`. Safe to call multiple times.
    func bootstrap() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PostHogAPIKey") as? String,
              !apiKey.isEmpty,
              apiKey != "$(POSTHOG_API_KEY)" else {
            // No API key configured — analytics is a no-op.
            // This lets us ship builds without a real key during development.
            return
        }
        let host = (Bundle.main.object(forInfoDictionaryKey: "PostHogHost") as? String)
            ?? "https://us.i.posthog.com"
        let config = PostHogConfig(apiKey: apiKey, host: host)
        config.captureApplicationLifecycleEvents = true
        config.sessionReplay = true
        PostHogSDK.shared.setup(config)
        // Honor persisted opt-in.
        applyOptInState(isOptedIn)
    }

    func setOptedIn(_ optIn: Bool) {
        UserDefaults.standard.set(optIn, forKey: optInKey)
        applyOptInState(optIn)
    }

    private func applyOptInState(_ optIn: Bool) {
        if optIn {
            PostHogSDK.shared.optIn()
        } else {
            PostHogSDK.shared.optOut()
        }
    }
}
