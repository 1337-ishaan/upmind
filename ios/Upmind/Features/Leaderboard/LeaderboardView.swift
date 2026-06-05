import SwiftUI

struct LeaderboardView: View {
    @State private var vm: LeaderboardViewModel
    @Environment(\.theme) private var theme

    init(syncWorker: SyncWorker) {
        _vm = State(wrappedValue: LeaderboardViewModel(syncWorker: syncWorker))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                yourStatsCard
                Picker("Window", selection: $vm.window) {
                    ForEach(LeaderboardViewModel.Window.allCases) { w in
                        Text(w.label).tag(w)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)

                List {
                    ForEach(vm.rows) { row in
                        HStack {
                            Text("#\(row.rank)")
                                .font(.subheadline)
                                .foregroundStyle(theme.textSecondary)
                                .frame(width: 50, alignment: .leading)
                            Text(row.name)
                                .font(.body)
                                .foregroundStyle(row.isYou ? theme.accentPrimary : theme.textPrimary)
                                .bold(row.isYou)
                            Spacer()
                            Text("\(row.rating)")
                                .font(.body).bold()
                                .foregroundStyle(theme.textPrimary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background(theme.surfaceBase)
            .navigationTitle("Leaderboard")
            .onAppear { vm.refresh() }
        }
    }

    private var yourStatsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Your rating")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)
                Text("\(vm.yourRating)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.accentPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("Top \(vm.yourPercentile)%")
                    .font(.subheadline)
                    .foregroundStyle(theme.textPrimary)
                Text("Rank #\(vm.yourRank)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .background(theme.surfaceElevated)
    }
}
