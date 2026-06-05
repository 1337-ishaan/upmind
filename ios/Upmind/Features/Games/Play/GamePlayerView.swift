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
            // Full result screen. "Play again" restarts the engine for
            // the same game; "Done" dismisses the player via
            // `\.dismiss` (pops the navigation stack).
            SessionResultView(
                result: result,
                onPlayAgain: { vm.start() }
            )
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
        case .reaction(let t):
            ReactionRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { pressed in
                    Task { await vm.answer(.reaction(pressed)) }
                }
            )
        case .sequence(let t):
            SequenceRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { items in
                    Task { await vm.answer(.sequence(items)) }
                }
            )
        case .grid(let t):
            GridRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { cell in
                    Task { await vm.answer(.grid(cell)) }
                }
            )
        case .numberLine(let t):
            NumberLineRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { v in
                    Task { await vm.answer(.numberLine(v)) }
                }
            )
        case .typed(let t):
            TypedRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { s in
                    Task { await vm.answer(.typed(s)) }
                }
            )
        case .sort(let t):
            SortRenderer(
                trial: t,
                lastCorrect: lastCorrect,
                onAnswer: { idx in
                    Task { await vm.answer(.sort(idx)) }
                }
            )
        case .recall(let t):
            // Recall has the same shape as Choice — render it with the
            // ChoiceRenderer. The `correctId` lives on the trial but the
            // renderer scores via the per-choice `correct` flag, which the
            // engine syncs at generator time. `mode` is nil because the
            // ChoiceRenderer doesn't read it.
            ChoiceRenderer(
                trial: ChoiceTrial(
                    id: t.id, index: t.index, difficulty: t.difficulty,
                    prompt: t.prompt, choices: t.choices, mode: nil
                ),
                lastCorrect: lastCorrect,
                onAnswer: { id in
                    Task { await vm.answer(.recall(id)) }
                }
            )
        }
    }
}
