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

    /// Set to `true` once `bootstrap()` has successfully configured the SDK.
    /// All `track(_:)` calls short-circuit when this is false, so we never
    /// hit the PostHog SDK before it's ready (or when no API key is set).
    private var isConfigured: Bool = false

    /// Known feature-flag keys. Centralized so callers don't fat-finger
    /// a flag name. PostHog itself owns the flag values.
    enum FeatureFlag: String {
        case paywallYearlyDefault = "paywall_yearly_default"
        case briefingGameVariant = "briefing_game_variant"
        case leaderboardFreeTierSize = "leaderboard_free_tier_size"
        case premiumPriceTest = "premium_price_test"
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
        isConfigured = true
    }

    /// Send a typed analytics event. No-op when the SDK isn't configured
    /// (no real PostHog key in dev) or the user has opted out — PostHogSDK
    /// respects the opt-in state set via `applyOptInState`.
    func track(_ event: AnalyticsEvent) {
        guard isConfigured else { return }
        PostHogSDK.shared.capture(event.name, properties: event.properties)
    }

    /// Trigger a refresh of feature flags from PostHog. Call after
    /// user identity changes (sign-in / sign-out) so flags reload.
    /// The PostHog iOS SDK exposes an async `reloadFeatureFlags` API;
    /// we wrap the call in a Task to keep the manager `@MainActor`.
    func refreshFeatureFlags() {
        guard isConfigured else { return }
        Task { @MainActor in
            PostHogSDK.shared.reloadFeatureFlags()
        }
    }

    /// Synchronous feature-flag reader. Stub for v1: PostHog's flags
    /// load asynchronously, so this always returns `fallback` for now.
    /// Replace with a cached `flags` dict refreshed by
    /// `refreshFeatureFlags()` once we wire up real flag reads.
    func featureFlag(_ flag: FeatureFlag, default fallback: Bool = false) -> Bool {
        return fallback
    }

    /// Variant-string reader (e.g. `briefing_game_variant` returns "stroop"
    /// or "flanker"). Stub for v1 — always returns the fallback.
    func featureFlagVariant(_ flag: FeatureFlag, default fallback: String) -> String {
        return fallback
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
