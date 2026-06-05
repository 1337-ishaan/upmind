# Upmind Swift Rebuild — Plan 3: Auth + Backend + Paywall

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire up sign-in (email + Apple), local-first session persistence, cloud sync to Supabase, RevenueCat subscription, premium gating, and the three main app screens (Today, Leaderboard, Profile) plus the onboarding flow. Output: a fully signed-in, cloud-syncing, paywalled MVP that's ready to ship with notifications and PostHog events (Plan 4).

**Architecture:** `AuthStore` (`@MainActor @Observable`) drives the app flow. SwiftData for local session cache. `SyncWorker` pushes pending sessions to Supabase in the background. `RevenueCatManager` is the single source of truth for `isPremium`. The five main screens (Today, Games, Leaderboard, Profile) live in a `TabView`. A modal paywall is presented when the user taps a premium game or a feature limit is hit. Onboarding is a 5-step flow (Welcome, Value, Survey, Briefing, Paywall) shown once for new users.

**Tech Stack:** Swift 6 + SwiftUI, @Observable, SwiftData, Supabase Swift SDK, RevenueCat iOS SDK, async/await, Apple Sign In via AuthenticationServices.

**Out of scope (handled in Plan 4):** Notifications, PostHog event tracking, polish, TestFlight, app store submission.

**UI constraint:** The user flagged the current UI as bad. Defer polish to a final round. For Plan 3, prioritize functional correctness over visual refinement.

---

## File structure (introduced in this plan)

```
ios/Upmind/
  Library/
    Supabase/
      SupabaseClient.swift          # already partially exists, expand
      AuthStore.swift                # NEW
      SessionRepository.swift        # NEW
      SkillScoreRepository.swift     # NEW
      LeaderboardRepository.swift    # NEW
      SyncWorker.swift               # NEW
    RevenueCat/
      RevenueCatManager.swift        # NEW
      Entitlement.swift              # NEW
    Persistence/
      SwiftDataStack.swift           # NEW
      CachedSession.swift            # NEW
  Features/
    Onboarding/
      Welcome/                       # NEW
      Value/                         # NEW
      Survey/                        # NEW
      Briefing/                      # NEW (mini-game)
      Paywall/                       # NEW
    Auth/
      SignIn/                        # NEW
      SignUp/                        # NEW
    Today/                           # NEW
    Leaderboard/                     # NEW
    Profile/                         # NEW
    RootTabView.swift                # NEW (replaces RootView)
  App/
    AppCoordinator.swift             # NEW
    RootView.swift                   # REPLACED
ios/Tests/
  FeatureTests/
    Auth/AuthStoreTests.swift
    Supabase/SyncWorkerTests.swift
    RevenueCat/RevenueCatManagerTests.swift
  IntegrationTests/
    AppFlowTests.swift               # anonymous → sign in → play → sync
```

---

## Rounds

### R1 — Supabase client + Auth (Email + Apple)
- Wire up the Supabase Swift SDK to a real project (use existing `ruqemqqomxrpdxorbijc` if reachable, otherwise a placeholder config)
- `AuthStore` with email/password + Apple Sign In
- `AuthRepository` thin wrapper over the SDK
- Sign In / Sign Up screens
- Anonymous user mode (default)

### R2 — SwiftData cache + SyncWorker
- `CachedSession` SwiftData model
- `SwiftDataStack` 
- `SyncWorker` that pushes pending sessions to Supabase
- Wire the GamePlayerView to write to the cache on session finish

### R3 — RevenueCat + Paywall + premium gating
- `RevenueCatManager` with `weekly` ($9.99) and `yearly` ($39.99) IAPs
- `Entitlement` enum + `isPremium` derived state
- Paywall screen with iOS 26 glass card
- Premium badge on executive-function games in catalog
- Tap a premium game while not subscribed → present paywall

### R4 — Today screen
- Daily drill card (picks a game for today based on construct rotation)
- Streak ring
- "Play today's drill" CTA
- Recent scores (last 3 sessions)

### R5 — Leaderboard screen
- Top 50 free + user's own rank
- Time window segmented control (Today/Week/Month/All)
- Per-construct filter
- Chess.com-style compact table

### R6 — Profile screen
- User identity (avatar, name, email)
- Premium status (or "Upgrade" CTA)
- Settings: theme (light/dark/system), notification opt-ins (UI only, no scheduling yet)
- Sign out
- Build number + version

### R7 — Onboarding flow
- Welcome (hero + value prop)
- ValueSlides (3 cards)
- Survey (7 questions, simple multiple choice)
- Briefing (mini-game: play one trial of Stroop)
- Paywall (re-uses R3's paywall)

### R8 — Final E2E test
- Anonymous user plays 3 games
- Signs in with email
- Sessions sync to Supabase
- Opens paywall, completes StoreKit test purchase
- Premium games unlock
- All tests pass

---

## Spec coverage

- ✅ Supabase auth (email + Apple) (R1)
- ✅ Onboarding (R7)
- ✅ SwiftData cache (R2)
- ✅ SyncWorker (R2)
- ✅ RevenueCat + Paywall (R3)
- ✅ Today (R4)
- ✅ Leaderboard (R5)
- ✅ Profile (R6)
- ✅ Premium gating (R3)
- ❌ Notifications (Plan 4)
- ❌ PostHog event tracking (Plan 4)
- ❌ UI polish (post-Plan 3 round)
- ❌ TestFlight / App Store (Plan 4)
