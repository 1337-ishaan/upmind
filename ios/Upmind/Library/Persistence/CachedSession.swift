import Foundation
import SwiftData

enum SyncState: String, Codable, Sendable {
    case pending
    case synced
    case failed
}

@Model
final class CachedSession {
    @Attribute(.unique) var localId: UUID
    var remoteId: String?
    var userIdentifier: String
    var sessionIdString: String
    var gameId: String
    var construct: String
    var startedAt: Date
    var finishedAt: Date
    var score: Int
    var accuracy: Double
    var rtMedianMs: Int
    var rtStddevMs: Int
    var drifts: Int
    /// Stored as a raw string so `#Predicate` can compare it directly.
    /// (SwiftData's Predicate macro doesn't support enum case comparisons.)
    var syncStateRaw: String
    var createdAt: Date

    var syncState: SyncState {
        get { SyncState(rawValue: syncStateRaw) ?? .pending }
        set { syncStateRaw = newValue.rawValue }
    }

    init(
        from result: SessionResult,
        userIdentifier: String
    ) {
        self.localId = UUID()
        self.remoteId = nil
        self.userIdentifier = userIdentifier
        self.sessionIdString = result.sessionId.uuidString
        self.gameId = result.gameId.rawValue
        self.construct = result.construct.rawValue
        self.startedAt = result.startedAt
        self.finishedAt = result.finishedAt
        self.score = result.score
        self.accuracy = result.accuracy
        self.rtMedianMs = result.rtMedianMs
        self.rtStddevMs = result.rtStddevMs
        self.drifts = result.drifts
        self.syncStateRaw = SyncState.pending.rawValue
        self.createdAt = Date()
    }
}
