import Foundation

/// The typed taxonomy of analytics events Upmind sends to PostHog.
/// Adding a new case is a deliberate act: the smoke test in
/// `EventTests.testAllEventsHaveNames` breaks if any case lacks a unique
/// `name` mapping. Keep names `snake_case` so they match the queries
/// already running in the PostHog dashboard.
enum AnalyticsEvent: Sendable {
    case appOpened(isFirstLaunch: Bool, appVersion: String)
    case onboardingStepViewed(step: String)
    case onboardingStepCompleted(step: String, durationMs: Int)
    case onboardingCompleted
    case authCompleted(method: String, isNewUser: Bool)
    case paywallViewed(source: String)
    case paywallPlanSelected(plan: String)
    case purchaseCompleted(plan: String, priceUsd: Double, isTrial: Bool)
    case purchaseFailed(plan: String, errorCode: String)
    case purchaseRestored
    case gameStarted(gameId: String, construct: String, isPremium: Bool)
    case gameCompleted(gameId: String, construct: String, score: Int, accuracy: Double, rtMedianMs: Int, durationMs: Int)
    case gameAborted(gameId: String, progress: Int)
    case premiumGameLocked(gameId: String)
    case notificationPermissionRequested(result: String)
    case notificationScheduled(category: String)
    case streakExtended(streakDays: Int)
    case streakLost(previousStreak: Int)
    case leaderboardViewed(window: String)
    case tabChanged(tab: String)

    /// Name sent to PostHog.
    var name: String {
        switch self {
        case .appOpened:                    return "app_opened"
        case .onboardingStepViewed:         return "onboarding_step_viewed"
        case .onboardingStepCompleted:      return "onboarding_step_completed"
        case .onboardingCompleted:          return "onboarding_completed"
        case .authCompleted:                return "auth_completed"
        case .paywallViewed:                return "paywall_viewed"
        case .paywallPlanSelected:          return "paywall_plan_selected"
        case .purchaseCompleted:            return "purchase_completed"
        case .purchaseFailed:               return "purchase_failed"
        case .purchaseRestored:             return "purchase_restored"
        case .gameStarted:                  return "game_started"
        case .gameCompleted:                return "game_completed"
        case .gameAborted:                  return "game_aborted"
        case .premiumGameLocked:            return "premium_game_locked"
        case .notificationPermissionRequested: return "notification_permission_requested"
        case .notificationScheduled:        return "notification_scheduled"
        case .streakExtended:               return "streak_extended"
        case .streakLost:                   return "streak_lost"
        case .leaderboardViewed:            return "leaderboard_viewed"
        case .tabChanged:                   return "tab_changed"
        }
    }

    /// String-string map of properties to send to PostHog.
    var properties: [String: String] {
        switch self {
        case .appOpened(let first, let ver):
            return ["is_first_launch": first ? "true" : "false", "app_version": ver]
        case .onboardingStepViewed(let step):
            return ["step": step]
        case .onboardingStepCompleted(let step, let ms):
            return ["step": step, "duration_ms": "\(ms)"]
        case .onboardingCompleted:
            return [:]
        case .authCompleted(let method, let isNew):
            return ["method": method, "is_new_user": isNew ? "true" : "false"]
        case .paywallViewed(let source):
            return ["source": source]
        case .paywallPlanSelected(let plan):
            return ["plan": plan]
        case .purchaseCompleted(let plan, let price, let trial):
            return ["plan": plan, "price_usd": String(format: "%.2f", price), "is_trial": trial ? "true" : "false"]
        case .purchaseFailed(let plan, let err):
            return ["plan": plan, "error_code": err]
        case .purchaseRestored:
            return [:]
        case .gameStarted(let g, let c, let p):
            return ["game_id": g, "construct": c, "is_premium": p ? "true" : "false"]
        case .gameCompleted(let g, let c, let score, let acc, let rt, let ms):
            return [
                "game_id": g, "construct": c,
                "score": "\(score)",
                "accuracy": String(format: "%.2f", acc),
                "rt_median_ms": "\(rt)",
                "duration_ms": "\(ms)",
            ]
        case .gameAborted(let g, let p):
            return ["game_id": g, "progress": "\(p)"]
        case .premiumGameLocked(let g):
            return ["game_id": g]
        case .notificationPermissionRequested(let r):
            return ["result": r]
        case .notificationScheduled(let c):
            return ["category": c]
        case .streakExtended(let s):
            return ["streak_days": "\(s)"]
        case .streakLost(let s):
            return ["previous_streak": "\(s)"]
        case .leaderboardViewed(let w):
            return ["window": w]
        case .tabChanged(let t):
            return ["tab": t]
        }
    }
}
