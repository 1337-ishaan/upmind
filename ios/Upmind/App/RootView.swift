import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme

    var body: some View {
        GameCatalogView()
            .background(theme.surfaceBase)
            .environment(\.theme, Theme.tokens(for: colorScheme))
    }
}

#Preview {
    RootView()
        .environment(\.theme, .light)
}
