import Foundation

/// A computed score for a completed session. Mirrors the React Native formula:
/// `score = round(accuracy × 100)`. This is the same formula as the existing
/// PWA prototype. An RT-stability modifier is reserved for v2 but not in v1.
struct ScoreBreakdown: Sendable, Equatable {
    let accuracy: Double
    let rtMedianMs: Int
    let rtStddevMs: Int
    let drifts: Int
    let score: Int
}

enum Scoring {

    /// Compute the final score for a session.
    /// - Parameters:
    ///   - correct: number of correctly-answered trials
    ///   - total: number of trials in the session
    ///   - rtMedianMs: median reaction time across all trials
    ///   - rtStddevMs: standard deviation of reaction times
    ///   - drifts: number of trials flagged as drift
    /// - Returns: a `ScoreBreakdown` with the computed score and metadata.
    static func score(
        correct: Int,
        total: Int,
        rtMedianMs: Int,
        rtStddevMs: Int,
        drifts: Int
    ) -> ScoreBreakdown {
        guard total > 0 else {
            return ScoreBreakdown(
                accuracy: 0, rtMedianMs: 0, rtStddevMs: 0, drifts: 0, score: 0
            )
        }
        let accuracy = Double(correct) / Double(total)
        let raw = accuracy * 100.0
        let score = Int(raw.rounded())
        return ScoreBreakdown(
            accuracy: accuracy,
            rtMedianMs: rtMedianMs,
            rtStddevMs: rtStddevMs,
            drifts: drifts,
            score: score
        )
    }

    /// Compute median of an integer array. Returns 0 for empty input.
    static func median(_ xs: [Int]) -> Int {
        guard !xs.isEmpty else { return 0 }
        let s = xs.sorted()
        let m = s.count / 2
        return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]
    }

    /// Compute standard deviation of an integer array. Returns 0 for empty input.
    static func standardDeviation(_ xs: [Int]) -> Int {
        guard !xs.isEmpty else { return 0 }
        let mean = Double(xs.reduce(0, +)) / Double(xs.count)
        let variance = xs.reduce(0.0) { $0 + (Double($1) - mean) * (Double($1) - mean) }
            / Double(xs.count)
        return Int(variance.squareRoot().rounded())
    }
}
