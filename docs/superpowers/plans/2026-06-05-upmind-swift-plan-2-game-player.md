# Upmind Swift Rebuild — Plan 2: Game Player

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the 8 SwiftUI trial renderers, the GamePlayerView shell, the GameCatalogView, and replace the 41 remaining placeholder generators with real implementations. Output: a fully playable 42-game SwiftUI app with no auth, no cloud, no paywall.

**Architecture:** SwiftUI views for each trial template. `@Observable` view model per screen, drives the `Engine` actor. Each renderer is a self-contained view that takes a `Trial` and emits a `TrialResponse` back via a closure. The catalog is a 2-column grid (iPhone) / adaptive (iPad) with a construct filter at the top.

**Tech Stack:** Swift 6 + SwiftUI, @Observable, AsyncStream consumption, no new SPM packages needed.

**Out of scope (handled in later plans):** Auth, Supabase sync, RevenueCat, paywall, onboarding, Today/Leaderboard/Profile screens, notifications, PostHog event tracking beyond the bootstrap.

**Spec reference:** `docs/superpowers/specs/2026-06-05-upmind-swift-rebuild-design.md` (Sections: "iOS 26 design system", "Game player (UI shell)", "Screen inventory", "Stack").

---

## File Structure (introduced in this plan)

```
ios/Upmind/
  Features/
    Games/
      Play/
        GamePlayerViewModel.swift
        GamePlayerView.swift
        Renderers/
          ChoiceRenderer.swift
          ReactionRenderer.swift
          SequenceRenderer.swift
          GridRenderer.swift
          NumberLineRenderer.swift
          TypedRenderer.swift
          SortRenderer.swift
        Components/
          ProgressHeader.swift           # trial N / total
          AnswerFeedback.swift           # correct/wrong flash
        Result/
          SessionResultView.swift
          SessionResultViewModel.swift
        SnapshotTests/
          (snapshot tests live in Tests/ snapshot dir)
      Catalog/
        GameCatalogView.swift
        GameCatalogViewModel.swift
        Components/
          GameCard.swift
          ConstructFilterChips.swift
      Generators/                       # one file per construct, 42 generators
        AttentionGenerators.swift
        MemoryGenerators.swift
        ProcessingGenerators.swift
        NumeracyGenerators.swift
        VerbalGenerators.swift
        ProblemGenerators.swift
        ExecutiveGenerators.swift
        GeneratorsRegistry.swift        # updated registry
ios/Tests/
  FeatureTests/
    Games/
      GamePlayerViewModelTests.swift
      GameCatalogViewModelTests.swift
  SnapshotTests/
    ChoiceRendererSnapshotTests.swift
    (more as needed)
```

---

## Rounds

This plan is dispatched in 6 rounds by 4 parallel agents (PM / Developer / Tester / Devil's Advocate). Each round is one Developer batch plus a parallel review.

### Round 1 — ViewModel + View shell + ChoiceRenderer
- GamePlayerViewModel (consumes Engine.events, exposes currentTrial, calls Engine.answer)
- GamePlayerView shell (routes on template)
- ChoiceRenderer (multiple choice with feedback flash)
- ProgressHeader component
- Snapshot test stub for ChoiceRenderer

### Round 2 — 7 more renderers
- ReactionRenderer (with minDelay/maxDelay between trials, signal at random time)
- SequenceRenderer (study phase + recall phase; sub-renderers for digits and blocks)
- GridRenderer (rows × cols, target cell)
- NumberLineRenderer (slider)
- TypedRenderer (TextField with regex validation)
- SortRenderer (categorize buttons)
- All wired into the View shell

### Round 3 — Result screen + Catalog + Navigation
- SessionResultView + ViewModel (shows score, accuracy, RT stats, "play again")
- GameCatalogView + ViewModel (2-col grid, construct filter, premium badges)
- GameCard component
- ConstructFilterChips component
- NavigationStack wiring from Catalog → Play → Result
- RootView shows a simple "Games" tab with the catalog

### Round 4 — 41 more game generators
- Replace the placeholder registry in `Generators.swift` with one file per construct
- Each generator implements its actual game logic
- All wired into `Generators.lookup`
- Add unit tests per generator (deterministic, valid output)

### Round 5 — Snapshot tests
- Snapshot tests for all 8 renderers using `swift-snapshot-testing`
- Set reference images

### Round 6 — Final verification
- All tests pass (existing 47 + new tests)
- App builds and launches in simulator
- Smoke test: tap a game, play one trial, see the result
- Update spec status

---

## Spec coverage

- ✅ 8 trial renderers (R1, R2)
- ✅ GamePlayerView shell (R1, R3)
- ✅ Result screen (R3)
- ✅ Catalog screen (R3)
- ✅ 41 real generators (R4)
- ✅ Snapshot tests (R5)
- ✅ E2E smoke test (R6)
- ❌ Auth (Plan 3)
- ❌ Cloud sync (Plan 3)
- ❌ Paywall (Plan 3)
- ❌ Onboarding (Plan 3)
- ❌ Today / Leaderboard / Profile (Plan 3)
- ❌ Notifications (Plan 4)
- ❌ PostHog event tracking (Plan 4)
