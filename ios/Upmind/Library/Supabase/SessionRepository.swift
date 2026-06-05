import Foundation
import Supabase

struct SessionRepository {
    let client: Supabase.SupabaseClient?

    init(client: Supabase.SupabaseClient? = SupabaseClient.shared) {
        self.client = client
    }

    func push(_ result: SessionResult, userId: String) async -> String? {
        guard let client else { return nil }
        let payload: [String: AnyJSON] = [
            "user_id": .string(userId),
            "game_id": .string(result.gameId.rawValue),
            "construct": .string(result.construct.rawValue),
            "started_at": .string(ISO8601DateFormatter().string(from: result.startedAt)),
            "duration_ms": .integer(Int(result.finishedAt.timeIntervalSince(result.startedAt) * 1000)),
            "score": .integer(result.score),
            "rt_median_ms": .integer(result.rtMedianMs),
            "rt_stddev_ms": .integer(result.rtStddevMs),
            "accuracy": .double(result.accuracy),
            "drifts": .integer(result.drifts),
        ]
        do {
            let inserted: [SessionRow] = try await client
                .from("sessions")
                .insert(payload)
                .select("id")
                .execute()
                .value
            return inserted.first?.id
        } catch {
            return nil
        }
    }
}

struct SessionRow: Decodable {
    let id: String
}
