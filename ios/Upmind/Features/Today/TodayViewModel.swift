import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class TodayViewModel {
    var recentSessions: [CachedSession] = []
    var streakDays: Int = 0
    var pendingSyncCount: Int = 0
    var lastSyncError: String?

    private let modelContext: ModelContext
    private let syncWorker: SyncWorker

    init(modelContext: ModelContext, syncWorker: SyncWorker) {
        self.modelContext = modelContext
        self.syncWorker = syncWorker
    }

    /// Refresh from local cache. Cheap; called on appear.
    func refresh() {
        var descriptor = FetchDescriptor<CachedSession>(
            sortBy: [SortDescriptor(\.finishedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 50
        recentSessions = (try? modelContext.fetch(descriptor)) ?? []
        streakDays = computeStreak(from: recentSessions)
        pendingSyncCount = syncWorker.pendingCount
        lastSyncError = syncWorker.lastError
    }

    /// Returns the GameDef for "today's drill". Rotates by day-of-year so the
    /// user gets a different game each day. Picked from the 37 non-premium games.
    var todaysGame: GameDef {
        let pool = Games.all.filter { !$0.isPremium }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return pool[day % pool.count]
    }

    private func computeStreak(from sessions: [CachedSession]) -> Int {
        // A streak is a run of consecutive calendar days with at least one session.
        let cal = Calendar.current
        let dayKeys: Set<String> = Set(sessions.map { s in
            cal.startOfDay(for: s.finishedAt).timeIntervalSince1970.description
        })
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while dayKeys.contains(day.timeIntervalSince1970.description) {
            streak += 1
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }
}
