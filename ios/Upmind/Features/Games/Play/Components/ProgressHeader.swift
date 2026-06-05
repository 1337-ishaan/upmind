import SwiftUI

/// "Trial N of M" header with a thin progress bar. Shown above every
/// renderer during a session.
struct ProgressHeader: View {
    let index: Int
    let total: Int
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text("Trial \(index + 1) of \(total)")
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
                Spacer()
            }
            ProgressView(value: Double(index + 1), total: Double(max(total, 1)))
                .tint(theme.accentPrimary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }
}
