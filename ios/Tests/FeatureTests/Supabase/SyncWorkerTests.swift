import XCTest
import SwiftData
@testable import Upmind

@MainActor
final class SyncWorkerTests: XCTestCase {

    func testEnqueuePersistsLocallyEvenWithoutUser() async {
        let context = ModelContext(SwiftDataStack.container)
        let worker = SyncWorker(repository: SessionRepository(client: nil), userIdProvider: { nil })
        let result = makeStubResult()
        await worker.enqueue(result, modelContext: context, userIdentifier: "anonymous")
        XCTAssertGreaterThan(worker.pendingCount, 0)
    }

    func testFlushWithoutUserLeavesPendingAlone() async {
        let context = ModelContext(SwiftDataStack.container)
        let worker = SyncWorker(repository: SessionRepository(client: nil), userIdProvider: { nil })
        await worker.enqueue(makeStubResult(), modelContext: context, userIdentifier: "anon")
        let pendingBefore = worker.pendingCount
        await worker.flush(modelContext: context)
        XCTAssertEqual(worker.pendingCount, pendingBefore, "Flush should not drop pending when there's no user")
    }

    func testSyncWorkerLastErrorIsNilInitially() async {
        let worker = SyncWorker(repository: SessionRepository(client: nil), userIdProvider: { nil })
        XCTAssertNil(worker.lastError)
    }

    private func makeStubResult() -> SessionResult {
        SessionResult(
            sessionId: UUID(),
            userIdentifier: "test",
            gameId: .stroop,
            construct: .attention,
            startedAt: Date(),
            finishedAt: Date(),
            trials: [],
            answers: [],
            score: 80,
            rtMedianMs: 500,
            rtStddevMs: 100,
            accuracy: 0.8,
            drifts: 0
        )
    }
}
