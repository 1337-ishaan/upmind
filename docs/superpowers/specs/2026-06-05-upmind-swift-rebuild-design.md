# Upmind Swift Rebuild — Design

## Overview

Rebuild the Upmind premium cognitive-training app natively in Swift / SwiftUI on iOS 26, deleting the existing Expo + React Native codebase, keeping the existing Supabase backend. The product is the same — 42 cognitive games across 7 constructs, executive function gated behind a RevenueCat subscription. Design language follows the iOS 26 community Figma reference and Apple HIG "Designing for games."

## Goals

- Native Swift app: better performance, better haptics, Game Center-ready, App Store-quality polish
- 1:1 port of all 42 games, 8 trial templates, scoring formula
- RevenueCat subscription: weekly $9.99, yearly $39.99, single `upmind_premium` entitlement
- iOS 26 design language: `.glassEffect()`, new toolbar styles, adaptive `TabView`
- Full Supabase sync (sessions, skill scores, leaderboard) with SwiftData local cache
- Local notifications (streak rescue, daily drill, weekly recap, premium renewal)
- PostHog analytics for funnels, retention, and feature flags
- Universal app (iPhone + iPad), min iOS 26.0

## Non-goals (v1)

- Game Center multiplayer / challenges / real-time leaderboard
- WatchOS / visionOS / macOS targets
- Server-side rendering of leaderboard
- A/B test framework beyond PostHog feature flags
- RTL / non-English localization
- Widgets / Live Activities

## Cleanup (delete the React Native app)

Hard delete these files and folders:

```
app/                 # expo-router routes
src/                 # RN source
__tests__/           # jest tests
android/             # native Android (not used; iOS-only Swift rebuild)
.expo/
babel.config.js
jest.config.js
package.json
package-lock.json
app.json
eas.json
index.html
landing.html
onboarding.html
iphone-frame.html
upmind-wireframes.html
upmind-app-wireframes.html
upmind-42-games-catalog.html
manifest.json
sw.js
tsconfig.json
web/                 # stale React-web stub (13-line index.html)
```

Keep:

```
supabase/            # backend, untouched
docs/                # design refs, future specs/plans
assets/              # icon, brain.png, app icon set
.opencode/
.superpowers/
.maestro/
.playwright-mcp/
.gitignore
```

## Project structure

```
upmind/                              # repo root (after RN cleanup)
  ios/
    Upmind.xcodeproj                 # single iOS app target
    Upmind/                          # source root
      App/
        UpmindApp.swift              # @main
        RootView.swift
        AppCoordinator.swift         # auth → onboarding → main flow
      DesignSystem/
        Tokens.swift                 # colors, spacing, typography (iOS 26)
        Theme.swift
        Components/
          PrimaryButton.swift
          Card.swift
          ProgressDots.swift
          SectionHeader.swift
          StatPill.swift
        Modifiers/
          Pressable.swift            # haptic-aware press effect
      Library/
        Supabase/
          SupabaseClient.swift
          AuthStore.swift
          SessionRepository.swift
          SkillScoreRepository.swift
          LeaderboardRepository.swift
          SyncWorker.swift
        RevenueCat/
          RevenueCatManager.swift
          Entitlement.swift
        Analytics/
          PostHogManager.swift       # PostHog wrapper
          Event.swift                # typed event names
        Notifications/
          NotificationCenter.swift   # local + remote
          NotificationCategory.swift
        Persistence/
          SwiftDataStack.swift
      Engine/                        # framework-agnostic game engine
        Trial.swift                  # 8 trial types
        Engine.swift                 # trial lifecycle, RT, drift
        Generator.swift              # protocol + 42 generators
        Scoring.swift
        Catalog.swift                # 42 GameDefs
        GameId.swift
      Features/
        Onboarding/
          Welcome/
          Value/
          Survey/
          Briefing/                  # mini-game hook
          Paywall/
        Auth/
          SignIn/
          SignUp/
        Today/
        Games/
          Catalog/
          Play/                      # GamePlayerView, 8 trial renderers
          Result/
        Leaderboard/
        Profile/
      Tests/
        EngineTests/
        FeatureTests/
        SnapshotTests/
  supabase/                          # existing — untouched
  docs/                              # existing design refs, future specs/plans
  assets/                            # icon, brain.png, app icon set
```

## Stack

- **iOS 26.0+** minimum target
- **Swift 6.0** strict concurrency
- **SwiftUI** throughout, `@Observable` for view state
- **SwiftData** for local session cache
- **Supabase Swift SDK** (existing schema: `sessions`, `skill_scores`, `users`, `leaderboard`)
- **RevenueCat iOS SDK** for weekly $9.99 / yearly $39.99 IAPs
- **PostHog iOS SDK** for analytics + feature flags
- **Xcode 16**, `xcodebuild` for CI
- **XCTest** + `swift-snapshot-testing`
- **Maestro iOS** (existing `.maestro/`) for smoke E2E

## Game engine (the heart)

### Trial types (`Engine/Trial.swift`)

Mirror the existing 8 templates as a Swift enum with associated values. Pure value types, no UI imports.

```swift
enum Trial: Sendable {
    // Template names match the RN engine 1:1; the only rename is `type → typed`
    // because `type` is a reserved Swift keyword.
    case choice(ChoiceTrial)        // RN: CHOICE
    case reaction(ReactionTrial)    // RN: REACTION
    case sequence(SequenceTrial)    // RN: SEQUENCE
    case grid(GridTrial)            // RN: GRID
    case recall(RecallTrial)        // RN: RECALL
    case numberLine(NumberLineTrial) // RN: NUMBERLINE
    case typed(TypedTrial)          // RN: TYPE
    case sort(SortTrial)            // RN: SORT
}

struct ChoiceTrial: Sendable {
    let id: UUID
    let index: Int
    let difficulty: Int
    let prompt: String
    let choices: [Choice]
    let mode: String?
}
```

### Engine (`Engine/Engine.swift`)

A Swift `actor` that runs the trial lifecycle. Listeners receive a single async stream of events. Engine is framework-agnostic (no SwiftUI, no UIKit imports) so it can be tested in isolation and reused in a watchOS app later.

```swift
actor Engine {
    enum Event: Sendable {
        case trial(Trial, index: Int)
        case answer(AnswerRecord)
        case finish(SessionResult)
    }

    private(set) var state: EngineState
    private let listener: (Event) async -> Void

    init(game: GameDef, listener: @escaping (Event) async -> Void)
    func start()
    func answer(_ response: TrialResponse) throws
    func abort()
}
```

State is private, accessed through async methods. RT measured via `ContinuousClock` (no Date skew). Drift detection preserved (`rtMs < 100` or repeated identical answer+RT).

### Generators (`Engine/Generator.swift`)

```swift
protocol TrialGenerator: Sendable {
    func makeTrial(index: Int, difficulty: Int) -> Trial
}

enum Generators {
    static let stroop: TrialGenerator = ...
    static let flanker: TrialGenerator = ...
    // ... 42 entries
}
```

Each generator is a pure function — same seed in → same trial out. Difficulty 1 baseline; engine can scale up between sessions later.

### Scoring (`Engine/Scoring.swift`)

```swift
struct ScoreBreakdown: Sendable {
    let accuracy: Double
    let rtMedianMs: Int
    let rtStddevMs: Int
    let drifts: Int
    let score: Int   // 0–100, formula preserved from RN
}
```

Same formula as RN: `score = round(accuracy × 100)` with RT stability modifier matching the existing `0.6 + 0.4 × stability` weight.

### Game catalog (`Engine/Catalog.swift`)

```swift
enum GameId: String, CaseIterable, Codable, Sendable {
    case stroop, flanker, gongo, /* ... 42 cases */
}

enum Construct: String, CaseIterable, Sendable {
    case attention, memory, processing, numeracy, verbal, problem, executive
}

struct GameDef: Sendable, Identifiable {
    let id: GameId
    let name: String
    let construct: Construct
    let template: TemplateKind
    let trials: Int
    let description: String
    let isPremium: Bool
}

let games: [GameDef] = [...]   // 42 entries, ported from GAMES
```

### Game player (UI shell)

Single SwiftUI screen that routes on `template` to one of 8 trial renderers. Each renderer is a focused subview that takes a `Trial` and emits a `TrialResponse` back to a `@Bindable` view model which calls `engine.answer(_:)`.

```swift
struct GamePlayerView: View {
    @State private var vm: GamePlayerViewModel
    var body: some View {
        switch vm.currentTrial {
        case .choice(let t):   ChoiceRenderer(trial: t, onAnswer: vm.answer)
        case .reaction(let t): ReactionRenderer(trial: t, onAnswer: vm.answer)
        // ... 8 branches
        case .none: ProgressHUD()
        }
    }
}
```

## Navigation

`NavigationStack` per tab, plus a `RootCoordinator` enum for cross-flow state:

```swift
enum AppFlow: Sendable {
    case loading
    case onboarding
    case auth
    case main
    case paywall(...)
}

@Observable @MainActor
final class AppCoordinator {
    var flow: AppFlow
    func bootstrap() async { /* check session, onboarding flag, paywall state */ }
}
```

Five tab roots under `main`:
- **Today** — daily drill card, streak, "play today's session"
- **Games** — 42-game catalog, filterable by construct
- **Leaderboard** — rank, percentile, sparkline, per-construct tabs
- **Profile** — settings, theme, premium status, sign out
- **Paywall** (modal) — presented when user taps a premium game or hits a feature limit

## Screen inventory

| Flow | Screens |
|---|---|
| Onboarding | Welcome, ValueSlides(×3), Survey(7q), Briefing (mini-game), Paywall |
| Auth | SignIn (email + Apple), SignUp |
| Main | Today, GameCatalog, GamePlayer, SessionResult, Leaderboard, Profile |
| Paywall | Plan picker (Weekly $9.99 / Yearly $39.99), Restore, success |

## iOS 26 design system

**Tokens** (`DesignSystem/Tokens.swift`):
- Semantic colors (not raw hex): `Color.surface.base`, `Color.surface.elevated`, `Color.accent.primary`, `Color.accent.soft`, `Color.text.primary`, `Color.text.secondary`, `Color.stroke.subtle`
- Spacing scale: `xxs 4 / xs 8 / sm 12 / md 16 / lg 24 / xl 32 / xxl 48`
- Type scale: `display / title1 / title2 / headline / body / callout / subhead / footnote / caption` — SF Pro, default 17pt body (per HIG)
- Radii: `sm 8 / md 14 / lg 22 / pill 999`
- iOS 26 specific: `glassEffect()` for prominent surfaces, `containerBackground` for tab/page bg

**Primitives**:
- `PrimaryButton` — filled, 50pt tall, 14pt corner radius, `.pressable` modifier (scale 0.97 on press, light haptic)
- `Card` — `.glassEffect()` (iOS 26) with subtle gradient border
- `ProgressDots` — for onboarding (calm motion, 480ms ease)
- `StatPill` — for skill scores and streak counts
- `SectionHeader` — eyebrow + title pattern

**iOS 26 specifics to lean on**:
- `.glassEffect()` on the paywall, briefing result, and the play screen chrome
- New `TabView` with `tabViewStyle(.sidebarAdaptable)` for iPad
- `.containerBackground()` on `NavigationStack` content
- New `ToolbarItemGroup` placements (top-bar trailing system image buttons)
- `ContentUnavailableView` for empty leaderboard, no sessions yet, etc.
- `Charts` (Swift Charts) for skill history sparkline

**Motion** (calm, Headspace-style):
- Page transitions: 480ms `easeInOut`
- Card press: 120ms `spring(response: 0.3, dampingFraction: 0.7)`
- Skill-score bumps: 600ms count-up animation
- Game answer feedback: 180ms correct/wrong flash, then auto-advance after 600ms

**Typography (HIG compliance)**:
- Body: 17pt
- Captions/labels: minimum 12pt (HIG floor is 11pt; we use 12pt+ everywhere)
- Buttons: 17pt medium, 44×44pt min tap target (HIG minimum)

**Layout**:
- All screens use `safeAreaInset` for chrome
- iPad uses `NavigationSplitView` for the main tab experience
- Game player full-bleed canvas, portrait-locked, no tab bar
- Respect Dynamic Type up to `.accessibility5`

## Monetization (RevenueCat)

**Setup:**
- RevenueCat project linked to App Store Connect
- Two products in App Store Connect, mirrored as **Entitlements** in RevenueCat:
  - `upmind_premium` entitlement
  - `weekly` — `upmind_weekly` — $9.99/week (auto-renewable)
  - `yearly` — `upmind_yearly` — $39.99/year (auto-renewable)
- One **Offering** with `weekly` as default and `yearly` highlighted as best value (subject to PostHog feature flag `paywall_yearly_default`)

**`RevenueCatManager` (`Library/RevenueCat/RevenueCatManager.swift`)**:
- Configured at app launch with the public API key from `Info.plist`
- `@Observable` singleton exposes `customerInfo`, `isPremium`, `availablePackages`, `purchase(_:)`, `restore()`
- Listens to `Purchases.shared.customerInfoStream` and broadcasts updates so the UI reactively locks/unlocks premium games
- `isPremium` derived from `customerInfo.entitlements["upmind_premium"]?.isActive == true`

**Paywall flow** (`Features/Onboarding/Paywall/`):
- iOS 26 glass card pattern, hero with the value prop
- Two pricing cards: `Weekly $9.99/week` and `Yearly $39.99/yr` (with "Save 92%" badge)
- Default-selected plan determined by PostHog feature flag `paywall_yearly_default`
- CTA: `Start Premium` → `RevenueCatManager.purchase(selectedPackage)`
- Secondary: `Restore Purchases` → `restore()` with success/failure sheet
- On success: persist to Supabase (`is_premium = true` on user row), dismiss paywall, route to Today, fire `purchase_completed` to PostHog
- On failure: inline error, fire `purchase_failed` to PostHog

**Premium gating:**
- Executive-function games (5): `trailmix`, `rulefind`, `setshift`, `planning`, `inhibit` show a "Premium" badge
- Tapping a premium game when not subscribed → present paywall as a sheet, fire `premium_game_locked` to PostHog
- Leaderboard: free users see top 50 + their own rank; premium users see top 200 + advanced filters (configurable via feature flag)

**Server-side receipt validation:**
- RevenueCat webhook → Supabase Edge Function → updates `users.is_premium` and `users.premium_until` from the actual `CustomerInfo`
- App reads premium status from local `CustomerInfo` for instant UX, but `EntitlementViewModel` always re-validates with RevenueCat on launch and on resume

## Backend sync (Supabase, kept as-is)

**Local cache (SwiftData)**: every session, score, and skill value is written locally first for instant UI, then synced to Supabase. Mirrors the existing RN pattern.

```swift
@Model
final class CachedSession {
    @Attribute(.unique) var localId: UUID
    var remoteId: String?
    var gameId: String
    var construct: String
    var startedAt: Date
    var finishedAt: Date
    var score: Int
    var accuracy: Double
    var rtMedianMs: Int
    var rtStddevMs: Int
    var drifts: Int
    var isPremium: Bool
    var syncState: SyncState      // .pending, .synced, .failed
}
```

**Sync worker** (`Library/Supabase/SyncWorker.swift`):
- Background `Task` that runs on app foreground, on session end, and every 5 minutes while signed in
- Pushes pending `CachedSession` rows to `sessions` table
- Pulls latest `skill_scores` and leaderboard window
- Conflict policy: server is source of truth; local `skillScores` overwritten from server pull after local pending writes have been pushed

**Auth**:
- Email/password via Supabase Auth
- Apple Sign-In required by App Store guidelines when offering social login
- Anonymous "try before you sign up" mode: local cache only, prompted to sign up on first paywall open

## Notifications

**Local notifications (default, no server needed at launch):**

| Category | Trigger | Copy | Notes |
|---|---|---|---|
| `streakRescue` | 8pm local if active streak, no session today | "Don't break your 3-day streak — play today's 3-minute drill." | Quiet hours 10pm–8am |
| `dailyDrill` | User's chosen time (default 9am local) if no session today | "Your daily 3-minute drill is ready." | Quiet hours respected |
| `weeklyRecap` | Sunday 7pm if ≥3 sessions that week | "You trained 4 of 7 days. Memory +6, Processing +4." | Skipped if user is under threshold |
| `premiumRenewal` | 3 days before auto-renew | "Your Upmind Premium renews in 3 days." | Required by App Store subscription policy |
| `premiumLapse` | 24h after subscription expires | "Your premium access ended today. Tap to see what you had." | One-shot |

**Permission strategy** (per HIG "Defer requests until the right time"):
- Do **not** request notification permission at first launch
- Request permission the first time a user taps "Notify me" on the Today screen, OR after they complete their 2nd session (whichever comes first)
- Pre-prompt with a custom in-app sheet explaining what we'll send (1–2 sentences) before the system prompt
- If denied: graceful fall-back, no nag screens, just hide the toggle
- Fire `notification_permission_requested` to PostHog with `result` (granted/denied)

**Remote push (Phase 2, after launch):**
- Marketing messages: opt-in only, max 2/week
- Game Center challenge invitations (when we add Game Center multiplayer)
- Re-engagement after 14 days inactive: "We saved your streak data. Come back and play a 2-minute drill."
- Implemented via APNs with a thin server (Supabase Edge Function or Cloudflare Worker)

**Implementation** (`Library/Notifications/NotificationCenter.swift`):
- Wraps `UNUserNotificationCenter`
- Categories: `.streakRescue`, `.dailyDrill`, `.weeklyRecap`, `.premiumRenewal`, `.premiumLapse`, `.marketing`
- Each category has its own thread identifier for grouping
- All scheduled notifications have an `expirationDate` so stale ones don't fire after the user opens the app
- Time zone aware: scheduled in `Calendar.current.timeZone`; re-scheduled on `NSSignificantTimeChangeNotification`

**Notification opt-out:**
- Per-category toggles in Profile → Notifications
- "Pause all for 24 hours" quick action
- Honors system-level Focus / Do Not Disturb

## Analytics (PostHog)

**`Library/Analytics/PostHogManager.swift`**:
- Wraps `PostHog-PostHog-iOS` (official Swift Package)
- Configured at app launch with the project API key from `Info.plist`
- `@Observable` singleton exposes `isOptedIn: Bool` (persisted in `UserDefaults`)
- PostHog iOS SDK respects App Tracking Transparency automatically

**Events tracked:**

| Event | Properties |
|---|---|
| `app_opened` | `is_first_launch`, `app_version` |
| `onboarding_step_viewed` | `step` (welcome, value, survey, briefing, paywall) |
| `onboarding_step_completed` | `step`, `duration_ms` |
| `onboarding_completed` | — |
| `auth_completed` | `method` (email, apple), `is_new_user` |
| `paywall_viewed` | `source` (onboarding, premium_game, profile) |
| `paywall_plan_selected` | `plan` (weekly, yearly) |
| `purchase_completed` | `plan`, `price_usd`, `is_trial` |
| `purchase_failed` | `plan`, `error_code` |
| `purchase_restored` | — |
| `game_started` | `game_id`, `construct`, `is_premium` |
| `game_completed` | `game_id`, `construct`, `score`, `accuracy`, `rt_median_ms`, `duration_ms` |
| `game_aborted` | `game_id`, `progress` (trials completed) |
| `premium_game_locked` | `game_id` |
| `notification_permission_requested` | `result` (granted/denied) |
| `notification_scheduled` | `category` |
| `streak_extended` | `streak_days` |
| `streak_lost` | `previous_streak` |
| `leaderboard_viewed` | `window` (today/week/month/all) |
| `tab_changed` | `tab` |

**Key funnels to monitor:**
- Onboarding completion rate per step
- Paywall view → plan select → purchase (overall + per plan)
- Daily/Weekly/Monthly active users
- D1 / D7 / D30 retention
- Game completion rate per game (to find drop-off)

**Privacy & opt-out:**
- Analytics enabled by default
- "Share anonymous usage data" toggle in Profile → Privacy
- Toggle-off immediately calls `PostHog.optOut()` to stop capture and clear queued events

**Feature flags (PostHog):**
- `paywall_yearly_default` — A/B test which plan is pre-selected
- `briefing_game_variant` — A/B test which mini-game is shown in onboarding
- `leaderboard_free_tier_size` — 50 vs 100 free visible ranks
- `premium_price_test` — future pricing experiments

## Testing strategy

- **Engine tests** (XCTest, fast, pure logic): every trial template × happy path, drift detection, scoring formula, generator determinism with a seeded RNG
- **View model tests**: premium gating logic, sync state machine, streak math
- **Snapshot tests** (`swift-snapshot-testing`) for the 8 trial renderers and the paywall
- **Supabase integration tests** against a local Supabase dev project (test schema, fixtures, no real users)
- **RevenueCat** uses the official StoreKit configuration file for simulator purchases
- **PostHog** events fired in tests use a `MockPostHogManager` that records events in-memory
- **Maestro iOS** (existing `.maestro/`) repurposed for the Swift app: smoke flow for onboarding, sign in, play one game, see result
- No UI tests beyond snapshots — surface is too big to maintain fragile e2e

## Delivery phases

1. **Phase 0** — RN cleanup, repo restructure, Xcode skeleton
2. **Phase 1** — DesignSystem + iOS 26 design tokens, primitives
3. **Phase 2** — Engine port (Trial types, Engine actor, 1 generator per template, scoring)
4. **Phase 3** — 8 trial renderers + GamePlayerView
5. **Phase 4** — Catalog of all 42 games (port generators)
6. **Phase 5** — Auth + Onboarding (Welcome, Value, Survey, Briefing)
7. **Phase 6** — Supabase sync (SwiftData cache, SyncWorker)
8. **Phase 7** — RevenueCat + Paywall + premium gating
9. **Phase 8** — Today, Leaderboard, Profile
10. **Phase 9** — Notifications (local + permission flow)
11. **Phase 10** — PostHog integration (events, feature flags, opt-out toggle)
12. **Phase 11** — Polish, accessibility audit, screenshots, TestFlight

### Phase ordering note for PostHog + Paywall

The paywall (Phase 7) reads the `paywall_yearly_default` feature flag from PostHog. To avoid blocking Phase 7 on manual PostHog dashboard setup, Phase 0 will:

1. Stand up a PostHog project (free tier) and add the iOS SDK to the project shell
2. Create the `paywall_yearly_default` flag with a `true` default value (yearly is the desired default)
3. Pre-create the `briefing_game_variant`, `leaderboard_free_tier_size`, and `premium_price_test` flags with safe defaults

This way Phase 7 can read the flag from day one, and Phase 10 is just "wire up the rest of the events."

## Open questions / risks

- iOS 26 adoption rate at GA+9 months: if too low, fall back to iOS 18 with conditional iOS 26 enhancements
- RevenueCat webhook needs a Supabase Edge Function deployed; we don't have a deploy pipeline yet — Phase 7 will stand one up
- 42 generators is the longest phase (4). Each is small but the count is high. Plan will suggest parallelizing with subagents
- The Figma community file (node 0-3329) is a reference, not a prescription; the spec derives its own iOS 26 design language
