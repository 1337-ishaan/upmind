import SwiftUI

/// Renderer for `ReactionTrial`. A simple visual reaction-time task:
/// the screen shows a "Wait…" placeholder; after a random delay in
/// `[minDelayMs, maxDelayMs]`, the `signal` appears and the button
/// flips to "TAP!". Tapping after the signal emits `.reaction(true)`,
/// tapping before emits `.reaction(false)`. The `lastCorrect` flash
/// turns the button green or red.
///
/// Round 2 simplifies to a single visible button; audio channels and
/// withhold trials (where `shouldPress == false`) fall out of the
/// engine's `isCorrect` check, which still scores them properly.
struct ReactionRenderer: View {
    let trial: ReactionTrial
    let lastCorrect: Bool?
    let onAnswer: (Bool) -> Void
    @Environment(\.theme) private var theme
    @State private var signalShown = false
    @State private var didAnswer = false
    @State private var delayTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt)
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Text(signalShown ? trial.signal : "Wait for it…")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(signalShown ? theme.accentPrimary : theme.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 220)
                .background(theme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .padding(.horizontal, Spacing.lg)
            Spacer()
            Button {
                guard !didAnswer else { return }
                didAnswer = true
                delayTask?.cancel()
                onAnswer(signalShown)
            } label: {
                Text(signalShown ? "TAP!" : "Hold…")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size + 16)
                    .background(buttonColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            .disabled(didAnswer)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
        .onAppear {
            let low = max(trial.minDelayMs, 0)
            let high = max(trial.maxDelayMs, low)
            let delay = Int.random(in: low...high)
            delayTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000)
                if !Task.isCancelled { signalShown = true }
            }
        }
        .onDisappear { delayTask?.cancel() }
    }

    private var buttonColor: Color {
        if lastCorrect == true { return theme.success }
        if lastCorrect == false { return theme.error }
        return signalShown ? theme.accentPrimary : theme.surfaceElevated.opacity(0.5)
    }
}
