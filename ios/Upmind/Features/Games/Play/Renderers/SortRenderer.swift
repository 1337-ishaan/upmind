import SwiftUI

/// Renderer for `SortTrial`. Show the `item` as a big card, then a
/// stack of category buttons. Tapping a category emits `.sort(idx)`.
/// After the user answers, the correct category flashes green on a
/// correct answer; on a wrong answer, the non-correct categories tint
/// red.
struct SortRenderer: View {
    let trial: SortTrial
    let lastCorrect: Bool?
    let onAnswer: (Int) -> Void
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text("Categorize:")
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
            Text(trial.item)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(theme.accentPrimary)
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(theme.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                .padding(.horizontal, Spacing.lg)
            Spacer()
            VStack(spacing: Spacing.sm) {
                ForEach(Array(trial.categories.enumerated()), id: \.offset) { idx, cat in
                    Button {
                        onAnswer(idx)
                    } label: {
                        Text(cat)
                            .font(.body).bold()
                            .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                            .background(categoryColor(idx))
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

    private func categoryColor(_ idx: Int) -> Color {
        guard let lastCorrect else { return theme.surfaceElevated }
        if idx == trial.answerIndex && lastCorrect { return theme.success.opacity(0.4) }
        if idx != trial.answerIndex && !lastCorrect { return theme.error.opacity(0.2) }
        return theme.surfaceElevated
    }
}
