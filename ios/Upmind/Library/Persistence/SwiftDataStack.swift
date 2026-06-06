import Foundation
import SwiftData

@MainActor
enum SwiftDataStack {
    static let container: ModelContainer = {
        let schema = Schema([CachedSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: memConfig)
        }
    }()
}
