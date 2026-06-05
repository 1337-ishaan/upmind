import SwiftUI

@MainActor
enum Theme {
    /// Upmind ships dark-first; user can opt into the light scheme in Profile (Phase 3 of Plan 3).
    static let defaultScheme: ColorScheme = .dark

    static func tokens(for scheme: ColorScheme) -> ColorTokens {
        switch scheme {
        case .light: return .light
        case .dark:  return .dark
        @unknown default: return .dark
        }
    }
}

private struct ThemeKey: EnvironmentKey {
    @MainActor
    static let defaultValue: ColorTokens = Theme.tokens(for: Theme.defaultScheme)
}

extension EnvironmentValues {
    /// Resolved at view-build time from the current color scheme.
    /// Read via `@Environment(\.theme) var theme`.
    var theme: ColorTokens {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
