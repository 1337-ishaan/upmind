import SwiftUI

/// Renderer for `ChoiceTrial` (and `RecallTrial`, which has the same shape).
/// Shows the prompt at the top, then a stack of large answer buttons.
/// After the user taps, shows brief correct/wrong feedback, then
/// auto-advances after 600ms (the auto-advance lives in a later round —
/// for now the renderer just emits the answer and disables further
/// tapping until the view model updates the trial).
struct ChoiceRenderer: View {
    let trial: ChoiceTrial
    let lastCorrect: Bool?
    let onAnswer: (String) -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.textPrimary)
                .padding(.horizontal, Spacing.lg)
            Spacer()
            VStack(spacing: Spacing.sm) {
                ForEach(trial.choices) { choice in
                    Button {
                        onAnswer(choice.id)
                    } label: {
                        Text(choice.label)
                            .font(.body)
                            .bold()
                            .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                            .padding(.vertical, Spacing.sm)
                            .background(backgroundColor(for: choice))
                            .foregroundStyle(theme.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                    }
                    .buttonStyle(.plain)
                    .disabled(lastCorrect != nil)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }

    private func backgroundColor(for choice: Choice) -> Color {
        guard let lastCorrect else { return theme.surfaceElevated }
        if choice.correct && lastCorrect == true { return theme.success.opacity(0.3) }
        if !choice.correct && lastCorrect == false { return theme.error.opacity(0.2) }
        return theme.surfaceElevated
    }
}
