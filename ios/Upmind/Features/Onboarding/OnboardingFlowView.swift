import SwiftUI
import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome, value, survey, briefing, paywall
}

@MainActor
@Observable
final class OnboardingFlowViewModel {
    var currentStep: OnboardingStep = .welcome
    private var stepStartTime: Date = Date()

    func advance() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            let now = Date()
            let durationMs = Int(now.timeIntervalSince(stepStartTime) * 1000)
            PostHogManager.shared.track(
                .onboardingStepCompleted(step: currentStep.analyticsName, durationMs: durationMs)
            )
            currentStep = next
            stepStartTime = now
            PostHogManager.shared.track(.onboardingStepViewed(step: next.analyticsName))
        }
    }

    func skip() {
        UserDefaults.standard.set(true, forKey: "Upmind.OnboardingComplete")
    }
}

private extension OnboardingStep {
    /// Stable identifier for analytics. Mirrors the `name` field of each
    /// step so dashboards can group by it.
    var analyticsName: String {
        switch self {
        case .welcome:  return "welcome"
        case .value:    return "value"
        case .survey:   return "survey"
        case .briefing: return "briefing"
        case .paywall:  return "paywall"
        }
    }
}

struct OnboardingFlowView: View {
    @State private var vm = OnboardingFlowViewModel()
    @Environment(\.theme) private var theme
    @State private var showBriefingPlayer: Bool = false
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            theme.surfaceBase.ignoresSafeArea()
            VStack(spacing: 0) {
                ProgressDots(
                    total: OnboardingStep.allCases.count,
                    current: vm.currentStep.rawValue
                )
                .padding(.top, Spacing.lg)

                Spacer()
                Group {
                    switch vm.currentStep {
                    case .welcome:    WelcomeStep(onContinue: { vm.advance() }, onSkip: { vm.skip(); onComplete() })
                    case .value:      ValueStep(onContinue: { vm.advance() })
                    case .survey:     SurveyStep(onContinue: { vm.advance() })
                    case .briefing:   BriefingStep(onContinue: { vm.advance() }, onPlay: { showBriefingPlayer = true })
                    case .paywall:    PaywallStep(onContinue: { vm.skip(); onComplete() }, onSkip: { vm.skip(); onComplete() })
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: vm.currentStep)
                Spacer()
            }
        }
        .onAppear {
            PostHogManager.shared.track(.onboardingStepViewed(step: vm.currentStep.analyticsName))
        }
        .fullScreenCover(isPresented: $showBriefingPlayer) {
            NavigationStack {
                GamePlayerView(game: Games.game(.stroop)!) { _ in
                    showBriefingPlayer = false
                    vm.advance()
                }
            }
        }
    }
}

// MARK: - Steps

private struct WelcomeStep: View {
    @Environment(\.theme) private var theme
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hex: "14B8A6"), Color(hex: "5EEAD4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(0.5)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(GradientTokens.cardAccent)
            }
            Spacer().frame(height: Spacing.lg)
            HeroText("Train your mind.\n3 minutes a day.")
            SubtitleText("Build cognitive skills with 42 science-backed games.")
            Spacer()
            PrimaryButton(
                "Get started",
                icon: "arrow.right",
                style: .gradient,
                action: onContinue
            )
            .padding(.horizontal, Spacing.lg)
            Button("Skip", action: onSkip)
                .foregroundStyle(theme.textSecondary)
                .padding(.bottom, Spacing.lg)
        }
    }
}

private struct ValueStep: View {
    @Environment(\.theme) private var theme
    let onContinue: () -> Void

    private let cards: [(String, String, String)] = [
        ("42 games", "Attention, memory, processing, numeracy, verbal, problem-solving, and executive function.", "brain.head.profile"),
        ("Honest measurement", "Reaction time + accuracy. No inflated scores, no streaks you didn't earn.", "scope"),
        ("Privacy first", "Anonymous by default. Your data stays on your device unless you sign in.", "lock.shield.fill"),
    ]

    var body: some View {
        VStack(spacing: Spacing.md) {
            TabView {
                ForEach(cards, id: \.0) { card in
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: card.2)
                            .font(.system(size: 80))
                            .foregroundStyle(theme.accentPrimary)
                        Text(card.0)
                            .font(.title2).bold()
                            .foregroundStyle(theme.textPrimary)
                        Text(card.1)
                            .font(.body)
                            .foregroundStyle(theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))

            Button("Continue", action: onContinue)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .background(theme.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
        }
    }
}

private struct SurveyStep: View {
    @Environment(\.theme) private var theme
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 80))
                .foregroundStyle(theme.accentPrimary)
            Text("What brings you to Upmind?")
                .font(.title2).bold()
                .foregroundStyle(theme.textPrimary)
                .multilineTextAlignment(.center)
            Text("(Survey coming in a future update — we just want to start you off.)")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button("Continue", action: onContinue)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .background(theme.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
        }
    }
}

private struct BriefingStep: View {
    @Environment(\.theme) private var theme
    let onContinue: () -> Void
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(theme.accentPrimary)
            Text("Try your first drill")
                .font(.title2).bold()
                .foregroundStyle(theme.textPrimary)
            Text("This is a Stroop test. Name the ink color of each word, ignoring what the word says.")
                .font(.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button("Play", action: onPlay)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .background(theme.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.lg)
            Button("Skip", action: onContinue)
                .foregroundStyle(theme.textSecondary)
                .padding(.bottom, Spacing.lg)
        }
    }
}

private struct PaywallStep: View {
    @Environment(\.theme) private var theme
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text("One last thing")
                .font(.title2).bold()
                .foregroundStyle(theme.textPrimary)
            Text("Premium unlocks 5 Executive Function games and unlimited history. Try it free.")
                .font(.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button("See plans", action: onContinue)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .background(theme.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                .padding(.horizontal, Spacing.lg)
            Button("Maybe later", action: onSkip)
                .foregroundStyle(theme.textSecondary)
                .padding(.bottom, Spacing.lg)
        }
    }
}
