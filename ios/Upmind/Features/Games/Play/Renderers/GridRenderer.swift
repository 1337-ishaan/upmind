import SwiftUI

/// Renderer for `GridTrial`. Shows a `rows × cols` grid of cells; the
/// user taps one. When `target` is non-nil it's surfaced as a heading
/// (e.g. "Find: ★"). After the user answers, the answer cell flashes
/// green for a correct answer or red-tints the other cells for a wrong
/// answer.
struct GridRenderer: View {
    let trial: GridTrial
    let lastCorrect: Bool?
    let onAnswer: (GridCell) -> Void
    @Environment(\.theme) private var theme

    private let columns: [GridItem]

    init(trial: GridTrial, lastCorrect: Bool?, onAnswer: @escaping (GridCell) -> Void) {
        self.trial = trial
        self.lastCorrect = lastCorrect
        self.onAnswer = onAnswer
        let cols = max(trial.cols, 1)
        self.columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: cols)
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text(trial.prompt)
                .font(.title3)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            if let target = trial.target {
                Text("Find: \(target)")
                    .font(.title.bold())
                    .foregroundStyle(theme.accentPrimary)
            }
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(0..<max(trial.rows, 0), id: \.self) { r in
                    ForEach(0..<max(trial.cols, 0), id: \.self) { c in
                        Button {
                            onAnswer(GridCell(row: r, col: c))
                        } label: {
                            Text(cellLabel(r, c))
                                .font(.title.bold())
                                .frame(maxWidth: .infinity, minHeight: MinTapTarget.size + 16)
                                .background(cellColor(r, c))
                                .foregroundStyle(theme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
                        }
                        .buttonStyle(.plain)
                        .disabled(lastCorrect != nil)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            Spacer()
        }
    }

    private func cellLabel(_ r: Int, _ c: Int) -> String {
        guard r < trial.cells.count, c < trial.cells[r].count else { return "" }
        return trial.cells[r][c]
    }

    private func cellColor(_ r: Int, _ c: Int) -> Color {
        guard let lastCorrect else { return theme.surfaceElevated }
        let isAnswer = (r == trial.answer.row && c == trial.answer.col)
        if isAnswer && lastCorrect { return theme.success.opacity(0.4) }
        if !isAnswer && !lastCorrect { return theme.error.opacity(0.2) }
        return theme.surfaceElevated
    }
}
