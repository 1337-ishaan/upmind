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
        VStack(spacing: Spacing.md) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Your streak")
                        .font(.subheadline)
                        .foregroundStyle(theme.textSecondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(vm.streakDays)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(GradientTokens.cardAccent)
                        Text(vm.streakDays == 1 ? "day" : "days")
                            .font(.title3)
                            .foregroundStyle(theme.textSecondary)
                    }
                }
                Spacer()
                streakRing
            }
            Text(streakSubtitle)
                .font(.subheadline)
                .foregroundStyle(theme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.accentPrimary.opacity(0.3),
                            theme.strokeSubtle.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var streakRing: some View {
        ZStack {
            Circle()
                .stroke(theme.strokeSubtle, lineWidth: 6)
                .frame(width: 70, height: 70)
            Circle()
                .trim(from: 0, to: min(Double(vm.streakDays) / 30.0, 1.0))
                .stroke(
                    GradientTokens.cardAccent,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(-90))
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(theme.accentPrimary)
        }
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
            PrimaryButton(
                "Play",
                icon: "play.fill",
                style: .gradient
            ) {
                onPlayGame(vm.todaysGame)
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(
                    LinearGradient(
                        colors: [
                            theme.accentPrimary.opacity(0.3),
                            theme.strokeSubtle.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
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
