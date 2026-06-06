import Foundation

/// A user's response to a trial. Each case maps 1:1 to a `Trial` template.
enum TrialResponse: Sendable, Equatable {
    case choice(String)              // ChoiceTrial: selected Choice.id
    case reaction(Bool)              // ReactionTrial: did the user press
    case sequence([String])          // SequenceTrial: ordered items (digit or "r:c")
    case grid(GridCell)              // GridTrial: tapped cell
    case recall(String)              // RecallTrial: selected Choice.id
    case numberLine(Double)          // NumberLineTrial: placed value
    case typed(String)               // TypedTrial: free text
    case sort(Int)                   // SortTrial: chosen category index
}

struct AnswerRecord: Sendable, Equatable {
    let trialIndex: Int
    let rtMs: Int
    let correct: Bool
    let response: TrialResponse
    /// True if this trial was flagged by the anti-cheat drift detector.
    let drift: Bool
}

struct SessionResult: Sendable, Equatable {
    /// Stable per-session identifier. Generated at engine init.
    let sessionId: UUID
    /// Anonymous device/user id for Plan 1. Resolved to a Supabase user id in Plan 3.
    let userIdentifier: String
    let gameId: GameId
    let construct: Construct
    let startedAt: Date
    let finishedAt: Date
    let trials: [Trial]
    let answers: [AnswerRecord]
    let score: Int
    let rtMedianMs: Int
    let rtStddevMs: Int
    let accuracy: Double
    let drifts: Int
}
