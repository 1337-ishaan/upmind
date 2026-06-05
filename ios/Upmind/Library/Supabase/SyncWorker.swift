import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class SyncWorker {
    private(set) var pendingCount: Int = 0
    private(set) var isSyncing: Bool = false
    private(set) var lastError: String?

    private let repository: SessionRepository
    private let userIdProvider: () -> String?

    init(
        repository: SessionRepository = SessionRepository(),
        userIdProvider: @escaping () -> String? = { nil }
    ) {
        self.repository = repository
        self.userIdProvider = userIdProvider
    }

    func enqueue(_ result: SessionResult, modelContext: ModelContext, userIdentifier: String) async {
        let cached = CachedSession(from: result, userIdentifier: userIdentifier)
        modelContext.insert(cached)
        try? modelContext.save()
        pendingCount += 1
        await flush(modelContext: modelContext)
    }

    func flush(modelContext: ModelContext) async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        lastError = nil

        let pendingRaw = SyncState.pending.rawValue
        let descriptor = FetchDescriptor<CachedSession>(
            predicate: #Predicate { $0.syncStateRaw == pendingRaw }
        )
        guard let pending = try? modelContext.fetch(descriptor) else { return }

        for session in pending {
            guard let userId = userIdProvider() else { continue }
            let stubResult = SessionResult(
                sessionId: UUID(uuidString: session.sessionIdString) ?? UUID(),
                userIdentifier: session.userIdentifier,
                gameId: GameId(rawValue: session.gameId) ?? .stroop,
                construct: Construct(rawValue: session.construct) ?? .attention,
                startedAt: session.startedAt,
                finishedAt: session.finishedAt,
                trials: [],
                answers: [],
                score: session.score,
                rtMedianMs: session.rtMedianMs,
                rtStddevMs: session.rtStddevMs,
                accuracy: session.accuracy,
                drifts: session.drifts
            )
            if let remoteId = await repository.push(stubResult, userId: userId) {
                session.remoteId = remoteId
                session.syncState = .synced
            } else {
                session.syncState = .failed
                lastError = "Failed to sync session \(session.sessionIdString)"
            }
            try? modelContext.save()
        }
        refreshPendingCount(modelContext: modelContext)
    }

    private func refreshPendingCount(modelContext: ModelContext) {
        let pendingRaw = SyncState.pending.rawValue
        let failedRaw = SyncState.failed.rawValue
        let descriptor = FetchDescriptor<CachedSession>(
            predicate: #Predicate { $0.syncStateRaw == pendingRaw || $0.syncStateRaw == failedRaw }
        )
        pendingCount = (try? modelContext.fetchCount(descriptor)) ?? 0
    }
}
