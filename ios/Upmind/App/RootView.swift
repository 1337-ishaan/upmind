import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 16) {
            Text("Upmind")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(theme.textPrimary)
            Text("Foundation ready. Engine next.")
                .foregroundStyle(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.surfaceBase)
        .environment(\.theme, Theme.tokens(for: colorScheme))
    }
}

#Preview {
    RootView()
        .environment(\.theme, .light)
}
