# Upmind Swift Rebuild — Plan 4: Ship

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add local notifications (5 categories, HIG-compliant permission flow), full PostHog event taxonomy (21 events), UI polish (the user's primary feedback), and prep for TestFlight. Output: shippable MVP ready to upload to App Store Connect.

**Architecture:** `NotificationCenter` wrapper around `UNUserNotificationCenter` with 5 categories and thread identifiers. `PostHogManager` exposes a typed `Event` enum with the full 21-event taxonomy. UI polish is a separate round that targets specific screens the user flagged.

**Tech Stack:** UserNotifications framework, PostHog iOS SDK, SwiftUI redesigns.

**Out of scope (post-launch):** Remote push (APNs), A/B test framework beyond feature flags, App Store review submission.

---

## File structure (introduced in this plan)

```
ios/Upmind/Library/
  Notifications/
    NotificationCenter.swift            # NEW
    NotificationCategory.swift          # NEW
    PermissionState.swift               # NEW
  Analytics/
    PostHogManager.swift                # EXPAND with Event enum
    Event.swift                         # NEW
ios/Upmind/Features/Profile/
  NotificationsSettingsView.swift       # NEW
ios/Tests/FeatureTests/
  Notifications/NotificationCenterTests.swift
  Analytics/EventTests.swift
ios/DesignSystem/                       # (Polish R3 creates new tokens/components)
  Components/GlassCard.swift            # NEW (R3)
  Components/PrimaryButton.swift        # REDESIGN (R3)
  Tokens.swift                          # REFINED (R3)
```

---

## Rounds

### R1 — Notifications
- `NotificationCenter` wrapper with 5 categories
- Permission state tracking (HIG-compliant deferral)
- 5 categories: streakRescue, dailyDrill, weeklyRecap, premiumRenewal, premiumLapse
- Per-category toggle in Profile → Notifications
- Time zone awareness, quiet hours
- Tests

### R2 — PostHog event taxonomy
- 21-event typed enum
- Wire up: `app_opened`, `onboarding_step_*`, `auth_completed`, `paywall_*`, `purchase_*`, `game_started/completed/aborted`, `premium_game_locked`, `notification_*`, `streak_*`, `leaderboard_*`, `tab_changed`
- Feature flag reader
- Tests

### R3 — UI Polish
- **PRIORITY:** The user explicitly flagged the UI as bad. This round overhauls the visual design with:
  - iOS 26 glass effect on cards (`.glassEffect()`)
  - Improved typography hierarchy
  - Better color contrast
  - More breathing room
  - Animated transitions
  - Empty states (no sessions, no leaderboard, etc.)
  - Onboarding illustrations (SF Symbols, hero text)
- Specific screens to redesign: GameCatalog, GamePlayer, SessionResult, Today, Profile, Paywall

### R4 — TestFlight + final E2E
- Build a release archive
- Verify the app runs end-to-end with no warnings
- Update spec status
- Final commit

---

## Spec coverage

- ✅ Notifications (5 categories, permission flow) (R1)
- ✅ PostHog event tracking (R2)
- ✅ UI Polish (R3)
- ✅ TestFlight (R4)
- ❌ Remote push (post-launch)
- ❌ App Store submission (manual)
