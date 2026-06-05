import Foundation
import Observation

struct LeaderboardRow: Identifiable, Equatable {
    let id = UUID()
    let rank: Int
    let name: String
    let rating: Int
    let isYou: Bool
}

@MainActor
@Observable
final class LeaderboardViewModel {
    enum Window: String, CaseIterable, Identifiable {
        case today, week, month, all
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }

    var window: Window = .week
    var rows: [LeaderboardRow] = []

    /// Placeholder for the user's own stats. Real implementation queries Supabase.
    var yourRating: Int { 1240 }
    var yourRank: Int { 142 }
    var yourPercentile: Int { 86 }

    private let syncWorker: SyncWorker

    init(syncWorker: SyncWorker) {
        self.syncWorker = syncWorker
    }

    /// Placeholder data. Real implementation queries the leaderboard view in Supabase.
    func refresh() {
        // Simulated top-50 + your row
        var mock: [LeaderboardRow] = []
        for rank in 1...50 {
            mock.append(LeaderboardRow(
                rank: rank,
                name: rank == 142 ? "You" : "Player \(rank)",
                rating: 1800 - rank * 8,
                isYou: rank == 142
            ))
        }
        // Insert your row if outside top 50
        if yourRank > 50 {
            mock.append(LeaderboardRow(rank: yourRank, name: "You", rating: yourRating, isYou: true))
        }
        rows = mock
    }
}
