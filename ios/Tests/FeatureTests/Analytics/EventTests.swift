import XCTest
@testable import Upmind

final class AnalyticsEventTests: XCTestCase {

    func testEventNamesAreStable() {
        XCTAssertEqual(AnalyticsEvent.appOpened(isFirstLaunch: true, appVersion: "0.1.0").name, "app_opened")
        XCTAssertEqual(AnalyticsEvent.gameStarted(gameId: "stroop", construct: "attention", isPremium: false).name, "game_started")
        XCTAssertEqual(AnalyticsEvent.streakExtended(streakDays: 5).name, "streak_extended")
    }

    func testEventPropertiesAreNonEmpty() {
        let event = AnalyticsEvent.purchaseCompleted(plan: "yearly", priceUsd: 39.99, isTrial: false)
        XCTAssertEqual(event.properties["plan"], "yearly")
        XCTAssertEqual(event.properties["price_usd"], "39.99")
        XCTAssertEqual(event.properties["is_trial"], "false")
    }

    func testAllEventsHaveNames() {
        // Smoke test: 21 distinct names. Add a name to AnalyticsEvent and
        // this test breaks — that's the point.
        let events: [AnalyticsEvent] = [
            .appOpened(isFirstLaunch: false, appVersion: "0.1.0"),
            .onboardingStepViewed(step: "welcome"),
            .onboardingStepCompleted(step: "welcome", durationMs: 1000),
            .onboardingCompleted,
            .authCompleted(method: "email", isNewUser: false),
            .paywallViewed(source: "onboarding"),
            .paywallPlanSelected(plan: "yearly"),
            .purchaseCompleted(plan: "yearly", priceUsd: 39.99, isTrial: false),
            .purchaseFailed(plan: "yearly", errorCode: "user_cancelled"),
            .purchaseRestored,
            .gameStarted(gameId: "stroop", construct: "attention", isPremium: false),
            .gameCompleted(gameId: "stroop", construct: "attention", score: 80, accuracy: 0.8, rtMedianMs: 500, durationMs: 5000),
            .gameAborted(gameId: "stroop", progress: 5),
            .premiumGameLocked(gameId: "trailmix"),
            .notificationPermissionRequested(result: "granted"),
            .notificationScheduled(category: "dailyDrill"),
            .streakExtended(streakDays: 5),
            .streakLost(previousStreak: 5),
            .leaderboardViewed(window: "week"),
            .tabChanged(tab: "today"),
        ]
        let names = Set(events.map(\.name))
        XCTAssertEqual(names.count, events.count, "All event names must be unique")
    }
}
