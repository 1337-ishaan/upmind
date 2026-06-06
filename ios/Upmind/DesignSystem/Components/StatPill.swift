import SwiftUI

/// Compact "value + label" block, used in dense rows such as the profile
/// stats and the paywall feature row.
struct StatPill: View {
    let value: String
    let label: String
    var icon: String? = nil
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            HStack(spacing: Spacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(theme.accentPrimary)
                }
                Text(value)
                    .font(.title2).bold()
                    .foregroundStyle(theme.textPrimary)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}
