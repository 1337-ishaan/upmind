import SwiftUI

/// Single screen that hosts the game player. Routes on `template` to the
/// appropriate renderer. The view model drives the engine; this view is
/// a thin presentation layer.
struct GamePlayerView: View {
    @State private var vm: GamePlayerViewModel
    @Environment(\.theme) private var theme

    init(game: GameDef) {
        // swiftlint:disable:next force_try
        _vm = State(wrappedValue: try! GamePlayerViewModel(game: game))
    }

    var body: some View {
        ZStack {
            theme.surfaceBase.ignoresSafeArea()
            content
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Quit") { vm.abort() }
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .onAppear { vm.start() }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView()
                .tint(theme.accentPrimary)
        case .playing(let trial, let index, let total, let lastCorrect):
            VStack(spacing: 0) {
                ProgressHeader(index: index, total: total)
                renderer(for: trial, lastCorrect: lastCorrect)
            }
        case .finished(let result):
            // Placeholder: real result view lands in Round 3.
            // For now show the score so we can verify end-to-end.
            VStack(spacing: Spacing.md) {
                Text("Session complete")
                    .font(.title2)
                    .foregroundStyle(theme.textPrimary)
                Text("Score: \(result.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accentPrimary)
                Text("Accuracy: \(Int(result.accuracy * 100))%")
                    .foregroundStyle(theme.textSecondary)
            }
        case .error(let message):
            VStack(spacing: Spacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(theme.error)
                Text(message)
                    .foregroundStyle(theme.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func renderer(for trial: Trial, lastCorrect: Bool?) -> some View {
        switch trial {
        case .choice(let t):
            ChoiceRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { id in
                    Task { await vm.answer(.choice(id)) }
                }
            )
        // Other templates land in Round 2. For now, a placeholder.
        default:
            VStack(spacing: Spacing.md) {
                Image(systemName: "hammer")
                    .font(.largeTitle)
                    .foregroundStyle(theme.textSecondary)
                Text("Renderer pending (Round 2)")
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}
