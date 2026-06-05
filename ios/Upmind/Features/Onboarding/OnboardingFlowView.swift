import SwiftUI
import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome, value, survey, briefing, paywall
}

@MainActor
@Observable
final class OnboardingFlowViewModel {
    var currentStep: OnboardingStep = .welcome

    func advance() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }

    func skip() {
        UserDefaults.standard.set(true, forKey: "Upmind.OnboardingComplete")
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
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text("Upmind")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accentPrimary)
            Text("Train your mind.\n3 minutes a day.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button("Get started", action: onContinue)
                .font(.title3).bold()
                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                .background(theme.accentPrimary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
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
