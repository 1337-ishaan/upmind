import Foundation

/// A pure function that produces one trial for a given game.
/// v1 uses an internal seeded RNG so the same (index, difficulty) gives
/// the same trial on every run — important for replay and testing.
///
/// `difficulty`: 1 = baseline. Generators MAY use this to scale
/// (e.g., N-back depth, grid size, distractor count). Generators that
/// don't scale MUST ignore it.
protocol TrialGenerator: Sendable {
    func makeTrial(index: Int, difficulty: Int) -> Trial
}

/// A small, deterministic xorshift RNG. Used by generators so test runs
/// produce stable trials. NOT cryptographically secure.
struct SeededRNG: Sendable, RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        var x = state
        x ^= x << 13
        x ^= x >> 7
        x ^= x << 17
        state = x
        return x
    }

    /// Returns a Double in [0, 1).
    mutating func unit() -> Double {
        Double(next() >> 11) / Double(1 << 53)
    }

    /// Returns an Int in [0, upperBound).
    mutating func int(upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        return Int(next() % UInt64(upperBound))
    }

    /// Returns an Int in [lower, upper].
    mutating func int(in range: ClosedRange<Int>) -> Int {
        let span = range.upperBound - range.lowerBound + 1
        return range.lowerBound + int(upperBound: span)
    }

    /// Pick a random element from a non-empty array.
    mutating func element<T>(from xs: [T]) -> T {
        precondition(!xs.isEmpty, "element(from:) called on empty array")
        return xs[int(upperBound: xs.count)]
    }

    /// Shuffle a copy of the input array.
    mutating func shuffled<T>(_ xs: [T]) -> [T] {
        var out = xs
        for i in (1..<out.count).reversed() {
            let j = int(upperBound: i + 1)
            out.swapAt(i, j)
        }
        return out
    }
}
