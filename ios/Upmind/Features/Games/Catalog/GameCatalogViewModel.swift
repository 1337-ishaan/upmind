import Foundation
import Observation

/// Drives the `GameCatalogView`. Owns the two filter inputs (selected
/// construct, search text) and exposes a single derived list
/// (`filteredGames`) that the view renders. Pure data — no engine
/// coupling, no async work.
@MainActor
@Observable
final class GameCatalogViewModel {
    var selectedConstruct: Construct? = nil
    var searchText: String = ""

    var filteredGames: [GameDef] {
        var games = Games.all
        if let c = selectedConstruct {
            games = games.filter { $0.construct == c }
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            games = games.filter {
                $0.name.lowercased().contains(q) || $0.description.lowercased().contains(q)
            }
        }
        return games
    }
}
