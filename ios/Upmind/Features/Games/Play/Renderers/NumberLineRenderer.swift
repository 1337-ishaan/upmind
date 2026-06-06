import SwiftUI

/// Renderer for `NumberLineTrial`. A horizontal slider from `min` to
/// `max`; the user drags to estimate `target`. The current value is
/// shown as a large numeral above the slider. After the user submits,
/// the submit button flashes green (correct within tolerance) or red
/// (wrong).
struct NumberLineRenderer: View {
    let trial: NumberLineTrial
    let lastCorrect: Bool?
    let onAnswer: (Double) -> Void
    @Environment(\.theme) private var theme
    @State private var value: Double

    init(trial: NumberLineTrial, lastCorrect: Bool?, onAnswer: @escaping (Double) -> Void) {
        self.trial = trial
        self.lastCorrect = lastCorrect
        self.onAnswer = onAnswer
        self._value = State(initialValue: (trial.min + trial.max) / 2)
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt)
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            Text(String(format: "%.0f", value))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accentPrimary)
            Slider(value: $value, in: trial.min...trial.max)
                .tint(theme.accentPrimary)
                .padding(.horizontal, Spacing.lg)
                .disabled(lastCorrect != nil)
            HStack {
                Text(String(format: "%.0f", trial.min))
                Spacer()
                Text(String(format: "%.0f", trial.max))
            }
            .font(.subheadline)
            .foregroundStyle(theme.textSecondary)
            .padding(.horizontal, Spacing.lg)
            Spacer()
            Button {
                onAnswer(value)
            } label: {
                Text("Submit")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                    .background(submitColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            .disabled(lastCorrect != nil)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var submitColor: Color {
        if lastCorrect == true { return theme.success }
        if lastCorrect == false { return theme.error }
        return theme.accentPrimary
    }
}
