import SwiftUI

/// Renderer for `TypedTrial`. Shows the prompt and a multi-line
/// `TextField` for the user's free-text answer. Submit emits the typed
/// text. The engine's regex (`answerPattern`) is the source of truth
/// for correctness — this renderer doesn't pre-validate.
///
/// Used for word-list recall, verbal fluency, etc.
struct TypedRenderer: View {
    let trial: TypedTrial
    let lastCorrect: Bool?
    let onAnswer: (String) -> Void
    @Environment(\.theme) private var theme
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt)
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            TextField(trial.placeholder ?? "Type your answer", text: $input, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, Spacing.lg)
                .disabled(lastCorrect != nil)
            Spacer()
            Button {
                onAnswer(input)
                input = ""
            } label: {
                Text("Submit")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                    .background(submitColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            .disabled(lastCorrect != nil || input.isEmpty)
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
