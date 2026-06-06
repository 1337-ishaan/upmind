import Foundation
import Observation

/// Drives the end-of-session results screen. Pure presentation: the
/// `SessionResult` arrives from the engine fully formed; this VM exposes
/// the display-shaped values (percentages, seconds, friendly labels) and
/// tracks the two user-driven actions (`playAgainRequested`,
/// `quitRequested`) so the view can react.
@MainActor
@Observable
final class SessionResultViewModel {
    let result: SessionResult
    var playAgainRequested: Bool = false
    var quitRequested: Bool = false

    init(result: SessionResult) {
        self.result = result
    }

    var accuracyPercent: Int { Int((result.accuracy * 100).rounded()) }
    var driftCount: Int { result.drifts }
    var rtMedianSeconds: Double { Double(result.rtMedianMs) / 1000.0 }
    var rtStddevSeconds: Double { Double(result.rtStddevMs) / 1000.0 }
    var durationSeconds: Int {
        Int(result.finishedAt.timeIntervalSince(result.startedAt).rounded())
    }
    var constructLabel: String { result.construct.label }
    var gameName: String {
        Games.game(result.gameId)?.name ?? result.gameId.rawValue
    }
}
