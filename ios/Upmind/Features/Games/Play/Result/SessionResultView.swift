import SwiftUI

/// End-of-session results screen. Shows the score, key per-session stats
/// (accuracy, median RT, RT variability, drifts, duration, trial count),
/// and offers "Play again" / "Done" actions. The "Done" button pops the
/// navigation stack via `\.dismiss`; "Play again" restarts the same game
/// by re-driving the player view model.
struct SessionResultView: View {
    @State private var vm: SessionResultViewModel
    let onPlayAgain: () -> Void
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    init(result: SessionResult, onPlayAgain: @escaping () -> Void) {
        _vm = State(wrappedValue: SessionResultViewModel(result: result))
        self.onPlayAgain = onPlayAgain
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Spacer().frame(height: Spacing.xl)
                Text("Session complete")
                    .font(.title2)
                    .foregroundStyle(theme.textSecondary)
                Text("\(vm.result.score)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(scoreColor)
                Text("\(vm.gameName) · \(vm.constructLabel)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                statsCard
                actions
                Spacer().frame(height: Spacing.xxl)
            }
            .padding(.horizontal, Spacing.lg)
        }
        .background(theme.surfaceBase)
    }

    private var scoreColor: Color {
        switch vm.result.score {
        case 80...: return theme.success
        case 50..<80: return theme.accentPrimary
        default: return theme.error
        }
    }

    private var statsCard: some View {
        VStack(spacing: Spacing.md) {
            statRow("Accuracy", "\(vm.accuracyPercent)%")
            statRow("Median RT", String(format: "%.2fs", vm.rtMedianSeconds))
            statRow("RT variability", String(format: "±%.2fs", vm.rtStddevSeconds))
            statRow("Drift events", "\(vm.driftCount)")
            statRow("Duration", "\(vm.durationSeconds)s")
            statRow("Trials", "\(vm.result.answers.count)")
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(theme.textSecondary)
            Spacer()
            Text(value).foregroundStyle(theme.textPrimary).bold()
        }
        .font(.body)
    }

    private var actions: some View {
        VStack(spacing: Spacing.sm) {
            Button {
                vm.playAgainRequested = true
                onPlayAgain()
            } label: {
                Text("Play again")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                    .background(theme.accentPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
            Button {
                vm.quitRequested = true
                dismiss()
            } label: {
                Text("Done")
                    .font(.body)
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}
