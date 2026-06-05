import SwiftUI
import SwiftData

struct TodayView: View {
    @State private var vm: TodayViewModel
    @Environment(\.theme) private var theme
    let onPlayGame: (GameDef) -> Void

    init(modelContext: ModelContext, syncWorker: SyncWorker, onPlayGame: @escaping (GameDef) -> Void) {
        _vm = State(wrappedValue: TodayViewModel(modelContext: modelContext, syncWorker: syncWorker))
        self.onPlayGame = onPlayGame
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    streakCard
                    todaysDrillCard
                    if vm.pendingSyncCount > 0 {
                        syncBanner
                    }
                    if !vm.recentSessions.isEmpty {
                        recentScoresCard
                    }
                }
                .padding(Spacing.lg)
            }
            .background(theme.surfaceBase)
            .navigationTitle("Today")
            .onAppear { vm.refresh() }
        }
    }

    private var streakCard: some View {
        HStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(theme.strokeSubtle, lineWidth: 8)
                    .frame(width: 80, height: 80)
                Text("\(vm.streakDays)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accentPrimary)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("\(vm.streakDays)-day streak")
                    .font(.title3).bold()
                    .foregroundStyle(theme.textPrimary)
                Text(streakSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
            Spacer()
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private var streakSubtitle: String {
        switch vm.streakDays {
        case 0: return "Play today to start a streak"
        case 1: return "Keep it going tomorrow"
        default: return "Don't break the chain"
        }
    }

    private var todaysDrillCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's drill")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
            Text(vm.todaysGame.name)
                .font(.title).bold()
                .foregroundStyle(theme.textPrimary)
            Text(vm.todaysGame.description)
                .font(.body)
                .foregroundStyle(theme.textSecondary)
            Button {
                onPlayGame(vm.todaysGame)
            } label: {
                Text("Play")
                    .font(.title3).bold()
                    .frame(maxWidth: .infinity, minHeight: MinTapTarget.size)
                    .background(theme.accentPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private var syncBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: vm.lastSyncError == nil ? "arrow.triangle.2.circlepath" : "exclamationmark.triangle")
                .foregroundStyle(vm.lastSyncError == nil ? theme.accentPrimary : theme.warning)
            Text(vm.lastSyncError ?? "\(vm.pendingSyncCount) session\(vm.pendingSyncCount == 1 ? "" : "s") waiting to sync")
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
            Spacer()
        }
        .padding(Spacing.sm)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }

    private var recentScoresCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent")
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
            ForEach(vm.recentSessions.prefix(5), id: \.localId) { session in
                HStack {
                    Text(session.gameId.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.body)
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    Text("\(session.score)")
                        .font(.body).bold()
                        .foregroundStyle(scoreColor(for: session.score))
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...: return theme.success
        case 50..<80: return theme.accentPrimary
        default: return theme.textSecondary
        }
    }
}
