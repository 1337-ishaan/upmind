import SwiftUI

/// Renderer for `SequenceTrial` (study-then-recall). Round 2 simplifies
/// to a single phase: show the items as a row, then a TextField where
/// the user types their recall. Items are space-separated — digits for
/// digit spans, "r,c" pairs for block (Corsi) sequences.
///
/// The placeholder generator always produces digit sequences `["3","7","1"]`,
/// so this flow works end-to-end for that case. Block sequences are
/// accepted as a free-text fallback; the spec for an interactive grid
/// is in a later round.
struct SequenceRenderer: View {
    let trial: SequenceTrial
    let lastCorrect: Bool?
    let onAnswer: ([String]) -> Void
    @Environment(\.theme) private var theme
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt ?? "Repeat the sequence")
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            HStack(spacing: Spacing.sm) {
                ForEach(Array(trial.items.enumerated()), id: \.offset) { _, item in
                    Text(itemLabel(item))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .frame(width: 64, height: 80)
                        .background(theme.surfaceElevated)
                        .foregroundStyle(theme.accentPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                }
            }
            .padding(.horizontal, Spacing.lg)
            Spacer()
            TextField("Type the sequence", text: $input)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, Spacing.lg)
                .disabled(lastCorrect != nil)
            Button {
                let parts = input
                    .split(whereSeparator: { $0.isWhitespace || $0 == "," })
                    .map { String($0) }
                onAnswer(parts)
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

    private func itemLabel(_ item: SequenceItem) -> String {
        switch item {
        case .digit(let d): return d
        case .block(let r, let c, _): return "\(r),\(c)"
        }
    }

    private var submitColor: Color {
        if lastCorrect == true { return theme.success }
        if lastCorrect == false { return theme.error }
        return theme.accentPrimary
    }
}
